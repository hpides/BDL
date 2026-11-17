# Distributed LLMs: preparation and single-node inference

In this tutorial, you prepare the cluster to run a large language model (LLM)
and generate text on **node01 alone**. In Task 3, you will distribute the
computation and connect two model instances in a conversation.

We use [distributed-llama](https://github.com/b4rtaz/distributed-llama/tree/v0.16.3)
and **Llama 3.2 1B Instruct Q40** throughout. These are pre-trained weights: this exercise performs inference, not training.

## 1. Cluster setup

| Host | Address | Preparation |
| --- | --- | --- |
| node01 | 10.0.0.1 | Build the runtime; download the model |
| node02 | 10.0.0.2 | Build the runtime |
| node03 | 10.0.0.3 | Build the runtime |
| node04 | 10.0.0.4 | Build the runtime |
| node05 | 10.0.0.5 | Distributed-llama only supports 1, 2, or 4 inference nodes, so node05 is just happy to be here |

Use your cluster's addresses if they differ.

## 2. Prepare runtime on node01–node04

On **each of node01–node04**, install the dependencies and clone the release:

```bash
sudo apt update
sudo apt install -y git build-essential python3 time
cd ~
git clone --branch v0.16.3 --depth 1 https://github.com/b4rtaz/distributed-llama.git
cd ~/distributed-llama
make dllama
```

## 3. Download the model on node01

On **node01**:

```bash
cd ~/distributed-llama
python3 launch.py llama3_2_1b_instruct_q40 -skip-run -skip-script
ls -lh models/llama3_2_1b_instruct_q40/
```

The download is approximately 1.7 GB. The launcher downloads the model
and tokenizer files. Check that they exist:

```text
models/llama3_2_1b_instruct_q40/dllama_model_llama3_2_1b_instruct_q40.m
models/llama3_2_1b_instruct_q40/dllama_tokenizer_llama3_2_1b_instruct_q40.t
```

Only node01 needs these files for this tutorial. Workers will receive their
share of the model from the coordinating node in the task.

## 4. Generate text

On **node01**, in the same terminal, define the input and run:

```bash
cd ~/distributed-llama

MODEL=models/llama3_2_1b_instruct_q40/dllama_model_llama3_2_1b_instruct_q40.m
TOKENIZER=models/llama3_2_1b_instruct_q40/dllama_tokenizer_llama3_2_1b_instruct_q40.t
PROMPT='A Raspberry Pi cluster connects several small computers. Explain how they can work together.'

mkdir -p logs
set -o pipefail

/usr/bin/time -f '%e' -o logs/example.time \
  ./dllama inference \
  --model "$MODEL" --tokenizer "$TOKENIZER" \
  --buffer-float-type q80 --nthreads 4 --max-seq-len 512 \
  --temperature 0 --seed 10 --steps 128 --prompt "$PROMPT" \
  2>&1 | tee logs/example.log
```

The variables exist only in the shell where you set them. Set them again when
opening another terminal.

```set -o pipefail``` makes the pipeline report failure if either the timed inference command or tee fails.

```/usr/bin/time -f '%e' -o logs/example.time``` measures the inference command’s elapsed wall-clock time, with -f '%e' formatting it as seconds and -o logs/example.time saving it to that file.

```2>&1 | tee logs/example.log``` combines error output with standard output and sends both to tee, which displays them in the terminal and saves them to logs/example.log.

This runs with four CPU threads, a context capacity of 512 token positions,
and deterministic sampling settings. `--steps 128` limits limits the run to 128 tokens total, including the prompt and generated response.
The answer can therefore end mid-sentence. 
`q80` uses 8-bit quantization for the intermediate data exchanged between nodes. This is separate from the model’s q40 format (4-bit).

At the end you will see:

- **Evaluation:** Processing of the prompt.
- **Prediction:** Generation of new tokens (the answer).

Inspect the exit status and log messages if a run ends before producing
the summary. `set -o pipefail` ensures that `tee` does not hide an inference failure.

This is your starting point for task 3.
