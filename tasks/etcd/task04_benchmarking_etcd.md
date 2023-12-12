## Task 4 - Benchmarking etcd

The fourth task is to benchmark etcd. This is an opportunity to (1) get familiar with using a popular and widely used distributed key-value store, (2) gain experience in benchmarking systems, and (3) learn how different workload parameters and cluster sizes can impact the performance of a key-value store cluster.

### Submission Info

Submit the following files packaged into a zip file named `group<groupID>-task04.zip`:
\- `task04.txt`
\- optional: `task04_bonus01.txt`
\- optional: `task04_bonus02.txt`

When adding answers, e.g., command outputs, to the submission documents, please make sure that you add a descriptive title or description so that it is clear what subtask your answers/output corresponds to. For example, add the subtask title above your answer/output. If multiple answers are required in one subtask, for example, the results of different benchmark configurations, add enough context to clarify how the results were generated. Add the different flags or executed commands to the submission document for different benchmark configurations.

Time estimation: less than two hours. Not all team members have to do everything together, but the team as a unit. You may assign subtasks to subgroups or individual persons of your team.

### etcd Cluster Preparation

Like in the tutorial, you can start the server with the following command:

```bash
etcd --config-file /opt/etcd/etcd.conf.yml
```

You probably have not seen much output from the etcd servers during the tutorial. This is the case, as the log level is set to `error`, i.e., the server only prints error logs. To see more information from the etcd server instances, change the log level in each server's config file to `info`. After modifying the config file, you can start the server again, and you should now see many `info` logs printed by the servers.

For the benchmarks in this task, the etcd cluster's servers will run on a subset of the Pi nodes {`node02`, `node03`, `node04`, `node05`}. `node01` will be the node from which you will send requests to the etcd cluster. You need to modify the number of etcd servers in the etcd cluster. Without further modifications of the server's config file, only start the server on `node02`.

Now, try to query the data that you added during the tutorial.

```bash
etcdctl --endpoints=10.0.0.2:2379,10.0.0.3:2379 get helloWorld
```

Alternatively, you can use the following since you set the domain names of the addresses in `/etc/hosts` of the Pis.

```bash
etcdctl --endpoints=node02:2379,node03:2379 get helloWorld
```

The client (`etcdctl`) will show you a `connection refused` warning. This is the case, as a quorum is not given when only one node is online in a two-node cluster. For a cluster with n members, a quorum is (n/2)+1. Therefore, start the server on `node03`.

Retrieve the members of the cluster with the following command. What is the status of the members? Add the `member list` output to your `task04.txt` submission file.

```bash
etcdctl --endpoints=node02:2379,node03:2379 member list --write-out=table
```

Note the IDs of the members. These are relevant for removing and adding cluster members.

#### Removing Members

If we only want to run a single-node cluster, we need to remove one of the initial two nodes. This can be done with the following command:

```bash
etcdctl --endpoints=<add endpoints here> member remove <add member ID here>
```

Use this command to remove the server on `node03` from the cluster. Verify the removal with the `member list` command. What is the status of the remaining member? Add the output to your `task04.txt` submission file.

Stop the server on `node03` and send the above get request again against the cluster.

#### Adding Members

To add the etcd node, make sure that its data directory (see in the configuration file) is deleted before you start the corresponding etcd server. Also, since the node is supposed to join an existing cluster, the additional parameter `initial-cluster-state` with the value `existing` needs to be added to the configuration file. You can check the other configuration parameters (e.g., `initial-cluster-token`) in the configuration file to see the exact notation.

Set up the etcd cluster with four servers on the Pi nodes 02 to 05.

What is the status of the four endpoints `node02`, `node03`, `node04`, and `node05`? Please add the output in table output format to your `task04.txt`.

#### Accessing Data

Using a get request with the prefix flag, you can retrieve all stored key-value pairs when using an empty key (`""`). Retrieve all key-value pairs.

```bash
etcdctl --endpoints=node02:2379,node03:2379,node04:2379,node05:2379 get "" --prefix
```

Similar to the above command, you can use the delete (`del`) operation with the same prefix to remove all key-value pairs. Now, delete all previously added key-value pairs.

### Benchmark Tool

With the benchmark tool, we will measure different workloads with different etcd cluster configurations. For using the benchmark tool, navigate to `/opt/etcd-main`, which you prepared while following the tutorial.

For an etcd server, the default database size is 2 GiB. You can control the maximum size with the `quota-backend-bytes` parameter in the configuration file. For each server node, set the database size to 8 GiB (`8589934592`).

#### Simple Write

Start with a simple write benchmark. Before running the benchmark, ensure all key-value pairs are deleted (`del "" --prefix`).

```bash
go run ./tools/benchmark --endpoints=<add endpoints> put --total 3000
```

Add the printed summary to `task04.txt`. Remember to make sure that you add a descriptive title or description to clarify what subtask your answers/output corresponds to. `Simple Write`, for example, is sufficient in this case.

#### Simple Write Multiple Keys

Retrieve all stored key-value pairs (`get "" --prefix`). You should only see one pair. Since we did not set the maximum number of keys before, only one was used. Run the benchmark again, but set the maximum number of possible keys, i.e., the key space size, to 100.

Add the printed summary to `task04.txt`.

#### Write - Multiple Clients

Delete all keys again (`del "" --prefix`).

The simple write benchmark runs took significantly longer than simple read benchmarks. Since we did not set the number of connections and clients before, only one client and one connection were used.
Run the `put` workload again with 3000 operations, a key space size of 100, one connection, and different numbers of clients. Note the difference in throughput (Requests/sec) compared to the previous benchmark configuration. Increase the number of clients, starting with 10, 20, and 50, and subsequently doubling the number of clients up to 1600. After each benchmark execution, delete all key-value pairs in the cluster.

Run the benchmark three times (three iterations) for each benchmark configuration.
Write down the number of clients and, for each iteration, the measured throughput (Requests/sec) in `task04.txt`.

#### Write - Multiple Clients & Connections

Run the `put` workload again with 10000 (10k) operations, a key space size of 100, and 1000 clients. Use 1, 2, 5, and 10 connections. After each benchmark execution, delete all key-value pairs in the cluster.

Run the benchmark three times (three iterations) for each benchmark configuration.
Write down the number of clients and, for each iteration, the throughput (Requests/sec) in `task04.txt`.

#### Writes - Increasing Values Sizes

Until now, we only used the default key and value sizes of 8 Byte. Now, we investigate the achieved throughput with different value sizes.
Run the `put` workload again with 10000 operations, a key space size of 100, 1000 clients, and 10 connections.
Start with a value size of 8 Byte and incrementally double the size up to 16384 Byte (i.e., 16 KiB).

Run the benchmark three times (three iterations) for each benchmark configuration.
Before each benchmark execution, delete all key-value pairs in the cluster.
Write down the value size and, for each iteration, the throughput (Requests/sec) in `task04.txt`.

#### Simple Read

Continue with a simple read request benchmark. For this, set up an etcd cluster with four nodes again.
First, add the key-value pair {`ANY_KEY`, `abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-+`} to the cluster using `etcdctl` and verify the successful insertion with retrieving the key-value pair (get command).
For each subsequent read benchmark execution in this task, ensure this key-value pair exists.
For the benchmark execution, use `ANY_KEY` as the search key.

```bash
go run ./tools/benchmark --endpoints=<add endpoints> range ANY_KEY --total 3000
```

Add the printed summary to `task04.txt`.

#### Read - Multiple Clients

The simple read benchmark runs took significantly shorter than simple write benchmarks. Similar to the simple write, we did not set the number of connections and clients before, so only one client and one connection were used. For the subsequent benchmark runs, we increase the number of operations to 50000 (50k).
Run the `range` workload again with 50k operations, one connection, and different numbers of clients. Note the difference in throughput (Requests/sec) compared to the previous benchmark configuration. Increase the number of clients, starting with 10, 20, and 50, and subsequently doubling the number of clients up to 3200.

Run the benchmark three times (three iterations) for each benchmark configuration.
Write down the number of clients and, for each iteration, the throughput (Requests/sec) in `task04.txt`.

#### Read - Multiple Clients & Connections

Run the `range` workload again with 50k operations and 3200 clients. Start with 1, 2, and 5 connections and incrementally double the number of connections up to 160.

Run the benchmark three times (three iterations) for each benchmark configuration.
Write down the number of connections and, for each iteration, the throughput (Requests/sec) in `task04.txt`.

#### Read - Latency Comparison

Review the output of the previous benchmark run (range operation, 50k operations, 3200 clients, 160 connections) or execute it again if the output is not available anymore. Afterward, run the benchmark again with only one client and one connection.
Add the summaries of both runs to `task04.txt`.
By what factors do the average latency and the throughput (requests per second) change? Write down your answer in `task04.txt`.

#### Read - Scalability Evaluation

Now, we want to investigate the scalability of etcd by using different cluster sizes. For this, use a benchmark configuration with 500000 (500k) operations, a key space size of 100, 2000 clients, 2000 connections, and a value size of 64.
Start with 4 cluster nodes and incrementally remove one node from the cluster (first node05, followed by node04 and node03). Note to also remove the removed endpoint(s) from the `etcdctl` or `benchmark` command.
For each cluster size, one run is sufficient.
Add the summary, response time histogram, and latency distribution of each run to `task04.txt`. Note: If multiple answers are required in one subtask, for example, the results of different benchmark configurations, add enough context so that it is clarified how the results were generated.

#### Bonus 1: Writes - Scalability

Investigate the scalability of etcd by using different cluster sizes for a write workload. For this, use a benchmark configuration with 500000 (500k) operations, a key space size of 100, 2000 clients, 2000 connections, and a value size of 64.
Start with 4 cluster nodes and incrementally remove one node from the cluster (first node05, followed by node04 and node03). Note to also remove the removed endpoint from the `etcdctl` or `benchmark` command.
For each cluster size, one run is sufficient.
Before each benchmark execution, delete all key-value pairs in the cluster.
Add the summary, response time histogram, and latency distribution of each run to `task04_bonus01.txt`.

#### Bonus 2: Serializable Read Scalability Evaluation

Perform the benchmarks required in `Read - Scalability Evaluation` again. However, this time, set the consistency mode to `Serializable`.
Add the summary, response time histogram, and latency distribution of each benchmark run to `task04_bonus02.txt`.
Can you observe any change in throughput or latency? Write your observations down in `task04_bonus02.txt`.

#### Presentation

One student representative demonstrates one or more benchmark runs in action for each group. This includes running selected workloads and presenting their benchmark measurements and observations.
In each lab session, we rotate and document the students representing the groups so every student gets their turn in the semester.

#### Further References

- etcd FAQ, https://etcd.io/docs/v3.5/faq/
- etcd cheat sheet, https://lzone.de/cheat-sheet/etcd

#### Troubleshooting

- warning `mvcc: database space exceeded`: If you already set the database size to 8 GiB (see https://etcd.io/blog/2023/how_to_debug_large_db_size_issue/), remove the data directory.
- You removed all data directories from the servers and want to start the cluster again. However, the servers do not start correctly. Note that `initial-cluster-state` needs to be set to `new` for all etcd nodes listed in `initial-cluster` of the cluster configuration.
