# Pi Chess — setup

Play against Chess Llama or watch two models play, with inference distributed
across your Raspberry Pi cluster. This ZIP contains the converted model, the
live board, and all C++ sources needed for compatible roots and workers.
**No model conversion, PyTorch, Hugging Face account, or runtime patches are needed.**

Debian/Ubuntu are recommended. Windows/macOS have not been tested and might fail during the setup scripts (if you want it to work on these OS as well lmk, I can try to expand it).

## 1. Extract the ZIP into a fresh folder

Download the supplied `pi-chess-2026-11-17.zip`. You need Python 3.9+ and `unzip`.

On your laptop:

```bash
unzip -n pi-chess-2026-11-17.zip -d "$HOME/pi-chess-lab"
cd "$HOME/pi-chess-lab/pi-chess"
python3 pi_chess.py verify
```

This guide uses these example addresses. Replace them with your own:

| Computer | Example IP | Runs |
| --- | --- | --- |
| Laptop | Can reach both roots | Browser, arbitrer, optional Stockfish |
| Pi 1 | `10.0.0.1` | API A / inference root A |
| Pi 2 | `10.0.0.2` | Worker A |
| Pi 3 | `10.0.0.3` | API B / inference root B |
| Pi 4 | `10.0.0.4` | Worker B |

A player uses **one root plus one worker**, so two players use all four Pis.
The APIs can play either color.

## 2. Copy the ZIP to the Pis

From the laptop's download folder, copy the **same ZIP** to each Pi. Change
`pi` below if your SSH username differs:

```bash
scp pi-chess-2026-11-17.zip pi@10.0.0.1:~/
scp pi-chess-2026-11-17.zip pi@10.0.0.2:~/
scp pi-chess-2026-11-17.zip pi@10.0.0.3:~/
scp pi-chess-2026-11-17.zip pi@10.0.0.4:~/
```

On **each Pi**, in an SSH terminal:

```bash
unzip -n "$HOME/pi-chess-2026-11-17.zip" -d "$HOME/pi-chess-lab"
cd "$HOME/pi-chess-lab/pi-chess"
python3 pi_chess.py verify
```

Use fresh extraction folders. `unzip -n` avoids overwriting existing files.
The full ZIP is used on every Pi to keep the instructions the same; workers
only use the runtime sources and their worker executable, not the model files.

## 3. One-time setup on each Pi

If needed, install the standard compiler/Python tools on the Pis:

```bash
sudo apt update
sudo apt install --no-install-recommends g++ python3 python3-venv unzip
```

Run the command for each Pi's role from its extracted `pi-chess` folder:

| Where | Setup command |
| --- | --- |
| Pi 1 / root A | `python3 pi_chess.py setup root --worker 10.0.0.2` |
| Pi 2 / worker A | `python3 pi_chess.py setup worker` |
| Pi 3 / root B | `python3 pi_chess.py setup root --worker 10.0.0.4` |
| Pi 4 / worker B | `python3 pi_chess.py setup worker` |

**Replace the worker IPs with yours.** Setup compiles locally, which can take
several minutes on a Pi. Wait for `Setup complete` on each machine.

All generated setup files stay under **`.pi-chess/`** in the extracted folder.
Repeating setup reuses a completed private build/environment. If a build failed, rerun setup;
incomplete builds are kept and a fresh build directory is used. Use
`--rebuild` to replace the selected build with a newly compiled copy while
keeping the earlier build files.

## 4. One-time laptop setup

Install any missing dependencies. ImageMagick
and the SVG libraries provide GIF export; Stockfish provides the evaluation bar:

```bash
sudo apt update
sudo apt install --no-install-recommends python3 python3-venv imagemagick librsvg2-2 libcairo2 stockfish
```

Stockfish engine does not show in Human vs AI games. 

In the laptop's extracted folder:

```bash
cd "$HOME/pi-chess-lab/pi-chess"
python3 pi_chess.py setup laptop --api-a 10.0.0.1 --api-b 10.0.0.3
```

**Replace these two addresses with your API-root IPs.** They are saved, so you
do not need to enter them every time. Setup checks GIF dependencies and creates
a private environment inside this folder.

## 5. Start the cluster

Keep **one SSH terminal per Pi** open. In each, go to
`~/pi-chess-lab/pi-chess`.
If another model is already using these Pis, stop it with Ctrl+C first so
memory and CPU are available; keep its installation files in place.

First start both workers:

| Where | Command |
| --- | --- |
| Pi 2 | `python3 pi_chess.py worker` |
| Pi 4 | `python3 pi_chess.py worker` |

Then start both APIs:

| Where | Command |
| --- | --- |
| Pi 1 | `python3 pi_chess.py api` |
| Pi 3 | `python3 pi_chess.py api` |

Wait for **`Chess Llama API ready`** in each API terminal. The roots load the
model and connect to their saved worker addresses first.

## 6. Open the board and play

On the **laptop**:

```bash
cd "$HOME/pi-chess-lab/pi-chess"
python3 pi_chess.py check
python3 pi_chess.py play
```

Open **http://127.0.0.1:8000/** in your laptop browser.

1. Choose **Watch API A vs API B**, **Play against API A**, or **Play against API B**.
2. For a human game, choose White or Black.
3. Click **Start game**.

Human moves support **dragging**, **clicking a piece then its destination**, or
entering SAN/UCI such as `Nf3` / `g1f3`. Choose the promotion piece before moving
a pawn onto its final rank. Moves are checked for legality; invalid model
replies are retried. The arbitrer detects checkmate and draws.

Temperature defaults to **0.7** so openings can vary. Other temperatures can be set with `-- temperature`.

Use **New game** in the page to play again without rerunning commands. Games
are saved in **`games/chess-match-.../`** with `board.svg`, `match.pgn`,
`transcript.jsonl`, and `state.json`. At game end or interruption, the arbitrer
also saves **`match.gif`**. Download buttons are below the bottom material
counter. Wait for `GIF saved` before closing the arbitrer terminal.

## After a reboot — only start, do not set up again

From `~/pi-chess-lab/pi-chess` on the appropriate computer:

1. Pi 2 and Pi 4: `python3 pi_chess.py worker`
2. Pi 1 and Pi 3: `python3 pi_chess.py api`
3. Laptop: `python3 pi_chess.py play`
4. Open http://127.0.0.1:8000/ and click **Start game**.

No compilation, pip install, environment activation, or model download is
needed again. Stop the laptop arbitrer first with Ctrl+C, wait for any GIF
export, then stop APIs and workers with Ctrl+C.

## Troubleshooting

- **Different IPs:** rerun `setup laptop --api-a NEW_ROOT_A --api-b NEW_ROOT_B`
  on the laptop, or `setup root --worker NEW_WORKER` on the affected root.
  Completed builds are reused. Restart the relevant process afterwards.
- **Connection refused:** leave the worker terminal running before starting
  its API, wait for `Chess Llama API ready`, then run `python3 pi_chess.py check`
  on the laptop. An unreachable worker can prevent its root from becoming ready.
- **Address already in use:** stop your earlier chess process with Ctrl+C.
  The helper never kills another process. For a different API/worker port,
  use `setup worker --port 10099`, `setup root --port 10099 --worker WORKER_IP:10099`,
  and full laptop URLs such as `setup laptop --api-a http://ROOT_A:10099/v1 --api-b http://ROOT_B:10099/v1`.
  Root and worker ports can also differ if the worker address names its actual port.
- **Laptop port 8000 busy:** `python3 pi_chess.py play --web-port 8001`, then open
  http://127.0.0.1:8001/.
- **Only two Pis:** set up both as roots, omit `--worker`, and run only the two
  APIs. Each model then runs on its root alone.
- **Only one model needed:** for human vs A, start root A and its worker only.
  Use `python3 pi_chess.py check --mode human-a` and
  `python3 pi_chess.py play --mode human-a`. Only API A is contacted when playing
  this mode. Either API can play either color.
- **Test a root without its worker:** `python3 pi_chess.py api --solo`.
- **Change variety:** `python3 pi_chess.py play --temperature 1.0`;
  `--temperature 0` chooses the highest-scoring legal move each time.
- **Compilation failed:** verify the ZIP, make sure this is a 64-bit Pi OS,
  install `g++` if missing, and retry setup with `--jobs 1`. For a new CPU or OS,
  extract a fresh ZIP and set up on that computer rather than copying a build.
- **Missing venv support:** install `python3-venv`, then rerun setup. Run setup
  as your normal user; do not use `sudo python3 ...`.
- **GIF dependency error:** install the laptop ImageMagick/librsvg/Cairo
  packages listed above. Stockfish is not required for GIFs.
- **Environment moved/copied:** extract and set up again at the final path.
  Python virtual environments are not portable; the ZIP itself is portable.
