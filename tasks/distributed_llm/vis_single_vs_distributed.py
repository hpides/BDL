"""Plot inference throughput and wall time from distributed-llama logs."""

import argparse
import csv
import math
from pathlib import Path
import re
from statistics import mean


def load_run(nodes, log_path, time_path):
    if nodes not in (1, 2, 4):
        raise ValueError("Node count must be 1, 2, or 4, including the root")
    text = re.sub(r"\x1b\[[0-9;]*m", "", log_path.read_text(encoding="utf-8"))
    summaries = re.findall(
        r"(?m)^Prediction[ \t]*\r?\n\s*nTokens:\s*(\d+)\s*\r?\n\s*tokens/s:\s*(\S+)", text,
    )
    if len(summaries) != 1:
        raise ValueError(f"{log_path}: expected one completed Prediction summary per log")
    count, speed = summaries[0]
    speed = float(speed)
    # Failed GNU time runs include a diagnostic as well as the elapsed seconds.
    wall = float(time_path.read_text(encoding="utf-8").strip())
    if int(count) < 1 or not all(math.isfinite(x) and x > 0 for x in (speed, wall)):
        raise ValueError(f"{log_path}: invalid token count, throughput, or elapsed time")
    return {"nodes": nodes, "wall_s": wall, "pred_tokens_s": speed,
            "pred_tokens": int(count), "log_file": str(log_path), "time_file": str(time_path)}


def plot_runs(rows):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    figure, axes = plt.subplots(1, 2, figsize=(10, 4.5), constrained_layout=True)
    for axis, field, label in zip(axes, ("pred_tokens_s", "wall_s"),
                                  ("Prediction throughput (tokens/s)", "Complete process time (seconds)")):
        nodes = sorted({row["nodes"] for row in rows})
        groups = [[row[field] for row in rows if row["nodes"] == n] for n in nodes]
        axis.plot(nodes, [mean(values) for values in groups],
                  marker="o", label="Mean")
        axis.scatter([row["nodes"] for row in rows], [row[field] for row in rows],
                     color="tab:orange", s=25, label="Individual runs", zorder=3)
        axis.set(xlabel="Inference nodes (root + workers)", ylabel=label, xticks=nodes, ylim=(0, None))
        axis.grid(alpha=0.3)
    figure.suptitle("Single-node and distributed inference")
    return figure


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--run", action="append", nargs=3, metavar=("NODES", "LOG", "TIME"), required=True,
                        help="Repeat for each measured run; provide 1, 2, and 4 node results")
    parser.add_argument("--output", type=Path, default=Path("plots/single-vs-distributed.png"))
    parser.add_argument("--csv", type=Path, default=Path("results/inference.csv"), help="Extracted measurements")
    args = parser.parse_args(argv)
    try:
        rows = [load_run(int(nodes), Path(log), Path(timing)) for nodes, log, timing in args.run]
        if {row["nodes"] for row in rows} != {1, 2, 4}:
            raise ValueError("Provide at least one --run for each of 1, 2, and 4 nodes")
        inputs = {Path(path).resolve() for _, log, timing in args.run for path in (log, timing)}
        if args.output.resolve() in inputs or args.csv.resolve() in inputs or args.output.resolve() == args.csv.resolve():
            raise ValueError("Use separate paths for input logs, timing files, CSV, and figure")
        figure = plot_runs(rows)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        figure.savefig(args.output, dpi=160)
        import matplotlib.pyplot as plt
        plt.close(figure)
        args.csv.parent.mkdir(parents=True, exist_ok=True)
        with args.csv.open("w", newline="", encoding="utf-8") as target:
            writer = csv.DictWriter(target, fieldnames=list(rows[0]))
            writer.writeheader()
            writer.writerows(rows)
    except ImportError:
        parser.exit(1, "Install Matplotlib in your plotting environment: python3 -m pip install matplotlib\n")
    except (OSError, ValueError) as error:
        parser.exit(1, f"Cannot plot inference results: {error}\n")
    print(f"Saved {args.output} and {args.csv}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
