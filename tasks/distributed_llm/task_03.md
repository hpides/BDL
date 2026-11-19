# Task 3 – Distributed LLM Inference

In this task you will run a language model across several Raspberry Pis, investigate its performance,
and connect two distributed model instances in a conversation. 

Complete the tutorial first. You should have the runtime on node01–node04 and a successful
single-node inference run on node01.

### 1. Distribute inference and investigate its performance

1.  Extend the single-node setup to **four nodes in total**: node01 participates
    in inference and coordinates workers on node02, node03, and node04. Each worker node should also run on **4 threads**.
    You may find useful hints in the documentation of the [distributed-llama GitHub](https://github.com/b4rtaz/distributed-llama/tree/main).

    If you see `Listening on 0.0.0.0:9998...` e.g., for port 9998, then this means the worker is ready. Leave its terminal open.

2.  How must the **command on node01** from the tutorial change to use these
    workers? Run it and save the command and output. Keep all other inference
    settings constant for the comparison below.

3.  Compare **one-node, two-node and four-node inference**. Keep four threads per node,
    context capacity 512, temperature 0, seed 10, and 128 total steps. Run one
    experiment at a time. 

    Track your command with

        mkdir -p logs
        /usr/bin/time -f '%e' -o logs/distributed_llm_run1.time \
        [your command]
        2>&1 | tee logs/distribured_llm_run1.log

    to capture wall-time and token speed.

    We have included a visualization script [vis_single_vs_distributed.py](vis_single_vs_distributed.py). Download the log folder to your workstation, for example, with:

        scp -r pi@node01:/home/pi/distributed-llama/logs .

    Then (with matplotlib installed) run

        python3 vis_single_vs_distributed.py \
          --run 1 logs/distributed_llm_run1.log logs/distributed_llm_run1.time \
          --run 2 logs/distributed_llm_run2.log logs/distributed_llm_run2.time \
          --run 4 logs/distributed_llm_run4.log logs/distributed_llm_run4.time \
          --csv logs/inference.csv \
          --output single-vs-distributed.png

    Adjust paths if needed.

    Take a look at the plot and logs of the workers during the multi-node inference run.

    Which parts of the model are distributed, and how does this explain the findings in the plots?

4.  The LLM can also be run with an interactive chat. What is the command to start such a session?


### 2. Two distributed model instances in a conversation

Reconfigure the cluster into **two independent instances of the same model**:

| Participant | API server and inference root | Its worker |
| --- | --- | --- |
| A | node01 | node02 |
| B | node03 | node04 |

Your workstation will forward the messages between the two APIs.

1.  Node03 now needs the **same model and tokenizer files** as node01. Copy the model directory from node01 to
    node03 or use the tutorial's download command there. 

2.  Start a worker on node02 and another on node04.
    Derive the API commands for node01 and node03 with the help of the [distributed-llama documentation](https://github.com/b4rtaz/distributed-llama/tree/main). Connect each root only to its assigned worker. It is recommended to use at least ```--max-seq-len 4096```, as this determines how many tokens are available for the whole discussion.

    Wait for both servers to finish loading.

    From your workstation, check both endpoints (here again assuming port 9998):

        curl http://10.0.0.1:9998/v1/models
        curl http://10.0.0.3:9998/v1/models

3.  Start the conversation with the
    supplied [conversation.py](conversation.py). Provide their system prompts / personas and
    an opening question. For example, from your workstation:

        mkdir -p chats
        set -o pipefail
        python3 conversation.py \
          --api-a http://10.0.0.1:9998/v1 \
          --api-b http://10.0.0.3:9998/v1 \
          --role-a 'You are David, a town planner who supports a car-free town centre. Respond to arguments from the other participant. Keep each reply to two short sentences.' \
          --role-b 'You are Rebecca, a shop owner who wants car access to the town centre. Respond to arguments from the other participant. Keep each reply to two short sentences.' \
          --question 'Should our town make its centre car-free?' \
          --max-tokens 512 \
          2>&1 | tee chats/conversation.txt

    Replies appear live as they arrive. You can record word counts and latency with `--csv [path to csv file]`. Use a fresh CSV filename for each run.

    A receives the opening question. Each answer then becomes the other
    participant's next user message. Each API request
    includes that participant's own system prompt and complete conversation
    history.

4.  Run the conversation twice: once with caching enabled (default) and
    once with `--no-cache`. Keep all other parameters identical, and start a fresh conversation for each run. Let each
    run continue for roughly **5 minutes**, using `--csv` to save the measurements
    in separate files. Plot cumulative generated tokens and response duration against time for each run with the supplied [vis_cache_vs_nocache.py](vis_cache_vs_nocache.py). Compare the results
    and explain the observed trends and differences between the two modes.

        python3 vis_cache_vs_nocache.py \
          --cache conversation-cache.csv \
          --no-cache conversation-no-cache.csv \
          --output cache-vs-no-cache.png

#### Bonus

1.  Monitor RAM usage on the API servers and workers in **Grafana** during both
    runs. Does memory consumption differ between cache and no-cache mode? Explain your observations in
    relation to how the runtime stores and reuses the conversation's computed
    state.

2.  Which parameter in the API launch commands from step 2 has a noticeable influence on RAM usage? Repeat the experiment with a different value,
    and restart the API servers. Observe RAM usage in Grafana and explain the change.

### Submission

Submit `group<groupID>-task03.zip` containing:

- `plots/`: Outputs of the two visualization scripts. For Bonus: Grafana screenshots showing labeled RAM usages.
- `discussion.md`: The textual answers to the questions in both parts

Do not include model files or compiled binaries.

### Presentation

One student per group demonstrates distributed inference and the conversation,
then explains the measured performance and how work and messages move between
nodes. You can use logs to support the explanation.
Rotate the representative as in the other lab sessions.
