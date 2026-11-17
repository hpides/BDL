"""Compare completed replies in cache/no-cache relay CSVs; discard incomplete rows."""

import argparse
import csv
from datetime import datetime, timezone
import math
from pathlib import Path


def load_run(path, no_cache):
    rows = []
    skipped = 0
    with path.open(newline="", encoding="utf-8") as source:
        reader = csv.DictReader(source)
        required = {"status", "started_at", "elapsed_s", "total_generated_words"}
        missing = required - set(reader.fieldnames or [])
        if missing:
            raise ValueError(f"{path}: missing columns: {', '.join(sorted(missing))}")
        for line, row in enumerate(reader, start=2):
            # Filter before parsing numbers: an interrupted final row may be incomplete.
            if (row.get("status") or "").strip() != "ok":
                skipped += 1
                continue
            try:
                stamp = datetime.fromisoformat(row["started_at"].replace("Z", "+00:00"))
                if stamp.tzinfo is None:
                    stamp = stamp.replace(tzinfo=timezone.utc)
                duration = float(row["elapsed_s"])
                words = int(row["total_generated_words"])
                if not math.isfinite(duration) or duration < 0 or words < 0:
                    raise ValueError("invalid duration or word count")
                if "no_cache" in row:
                    expected = "true" if no_cache else "false"
                    if (row["no_cache"] or "").strip().lower() != expected:
                        raise ValueError(f"expected no_cache={expected}; check the input file order")
            except (ValueError, TypeError, AttributeError) as error:
                raise ValueError(f"{path}, CSV line {line}: {error}") from error
            rows.append({"started_at": stamp.astimezone(timezone.utc),
                         "elapsed_s": duration, "total_generated_words": words})
    if not rows:
        raise ValueError(f"{path}: no completed replies (status=ok)")
    rows.sort(key=lambda row: row["started_at"])
    origin = rows[0]["started_at"]
    for row in rows:
        row["minutes"] = (row["started_at"] - origin).total_seconds() / 60
    return rows, skipped


def plot_runs(cached, uncached):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    figure, duration_axis = plt.subplots(figsize=(11, 5.5), constrained_layout=True)
    words_axis = duration_axis.twinx()
    lines = []
    for label, rows, style in (("Cache", cached, "-"), ("No cache", uncached, "--")):
        times = [row["minutes"] for row in rows]
        lines += duration_axis.plot(times, [row["elapsed_s"] for row in rows],
                                    color="tab:blue", linestyle=style, marker="o",
                                    label=f"{label}: response duration")
        lines += words_axis.plot(times, [row["total_generated_words"] for row in rows],
                                 color="tab:orange", linestyle=style, marker="s",
                                 label=f"{label}: cumulative words")
    duration_axis.set(xlabel="Time since each run's first request (minutes)",
                      ylabel="Complete response duration (seconds)", ylim=(0, None))
    words_axis.set(ylabel="Cumulative generated words (A + B)", ylim=(0, None))
    duration_axis.yaxis.label.set_color("tab:blue")
    duration_axis.tick_params(axis="y", labelcolor="tab:blue")
    words_axis.yaxis.label.set_color("tab:orange")
    words_axis.tick_params(axis="y", labelcolor="tab:orange")
    duration_axis.grid(alpha=0.3)
    duration_axis.legend(handles=lines, loc="upper left")
    duration_axis.set_title("Cache comparison")
    return figure


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cache", type=Path, required=True, help="Relay CSV with normal prefix reuse")
    parser.add_argument("--no-cache", type=Path, required=True, help="Relay CSV produced with --no-cache")
    parser.add_argument("--output", type=Path, default=Path("plots/cache-vs-no-cache.png"))
    args = parser.parse_args(argv)
    try:
        if args.cache.resolve() == args.no_cache.resolve():
            raise ValueError("Provide separate cache and no-cache CSVs")
        if args.output.resolve() in {args.cache.resolve(), args.no_cache.resolve()}:
            raise ValueError("The output path must differ from the input CSVs")
        cached, skipped_cache = load_run(args.cache, no_cache=False)
        uncached, skipped_no_cache = load_run(args.no_cache, no_cache=True)
        figure = plot_runs(cached, uncached)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        figure.savefig(args.output, dpi=160)
        import matplotlib.pyplot as plt
        plt.close(figure)
    except ImportError:
        parser.exit(1, "Install Matplotlib in your plotting environment: python3 -m pip install matplotlib\n")
    except (OSError, ValueError) as error:
        parser.exit(1, f"Cannot plot cache comparison: {error}\n")
    print(f"Cache: {len(cached)} completed, {skipped_cache} excluded; "
          f"no cache: {len(uncached)} completed, {skipped_no_cache} excluded.")
    print(f"Saved {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
