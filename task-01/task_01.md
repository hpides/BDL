## Task 1 - Scalable Data Processing with Hadoop

The first task is to operate and tune Hadoop for processing larger amounts of data. For this, you will generate and analyze larger text files that are based on our WordCount example in the tutorial. This is an opportunity to: (1) get familiar with using a popular and widely deployed MapReduce system, and (2) learn knobs at the storage, execution, and scheduler levels that impact performance and scalability.

### Step 1: Baseline Setup

1. Copy the following WordCount MapReduce program and text file to your cluster:

```
scp ./task01/WordCount.java pi@node01:~/
scp ./task01/data_file pi@node01:~/
```

1. Connect to your cluster and compile the WordCount program:

```
ssh pi@node01
```

```
hadoop com.sun.tools.javac.Main WordCount.java
jar cf WordCount.jar WordCount*.class
rm 'WordCount\$IntSumReducer.class' 'WordCount\$TokenizerMapper.class' WordCount.class 
```

1. As an initial setting, set the minimum amount of allocated memory per task in the YARN scheduler. Open `/opt/hadoop/etc/hadoop/yarn-site.xml` and add/change this configuration:

```
<property>
    <name>yarn.scheduler.minimum-allocation-mb</name>
    <value>8192</value>
</property>
```

1b. If you later receive an `Error: Java Heap Space`, then insert the following lines into `/opt/hadoop/etc/hadoop/mapred-site.xml`:

```
<property>
    <name>mapreduce.map.java.opts</name>
    <value>-Xmx4096m</value>
</property>
```
This solution is outlined in the (Stack Overflow Post by User Amar)[https://stackoverflow.com/questions/15609909/error-java-heap-space]


1. Start HDFS and YARN:

```
/opt/hadoop/sbin/start-dfs.sh 
/opt/hadoop/sbin/start-yarn.sh
/opt/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver
```

If YARN has been running, restart it via:

```
/opt/hadoop/sbin/stop-yarn.sh
/opt/hadoop/sbin/start-yarn.sh 
```

### Step 2: Data Generation

1. Concatenate the supplied text file to itself 12 times to generate a 128 MB file.  
   (This may take a minute)

```
cp data_file data_file_copy 
for i in {1..12}; do cat data_file >> data_file_copy; cp data_file_copy data_file; done
```

1. Check the resulting file size by running `ls -l -h`. The output should be as follows:

```
pi@node01:~ $ ls -l -h
[...]
-rw-r--r-- 1 pi pi 128M Oct 30 10:16  data_file
-rw-r--r-- 1 pi pi 128M Oct 30 10:12  data_file_copy
[...]
```

1. Copy the file to HDFS with a replication factor of 1:

```
hadoop fs -D dfs.replication=1 -copyFromLocal data_file /WordCount/input/128mb_block1_rep1
```

You can browse the HDFS web UI on `node01:50070` under `Utilities -> Browse the file system` to check the state of the file system:

### Step 3: MapReduce Program with Baseline Setup

```
hadoop jar WordCount.jar WordCount /WordCount/input/128mb_block1_rep1 /WordCount/output
```

You can track the job in the Hadoop web UI under the job URL, which is printed to the console.

```
2023-10-30 10:49:59,381 INFO impl.YarnClientImpl: Submitted application application_1698658156534_0002
2023-10-30 10:49:59,540 INFO mapreduce.Job: The url to track the job: http://node01:8088/proxy/application_1698658156534_0002/
2023-10-30 10:49:59,543 INFO mapreduce.Job: Running job: job_1698658156534_0002
2023-10-30 10:50:22,088 INFO mapreduce.Job: Job job_1698658156534_0002 running in uber mode : false
2023-10-30 10:50:22,091 INFO mapreduce.Job:  map 0% reduce 0%
```

The Grafana monitoring web UI is available under `node01:3000`.  
  
For reference, this took 1m51.511s on our cluster.

### Step 4: Tuning Hadoop MapReduce

The suboptimal baseline performance is, amongst others, a result of Hadoop not being able to exploit all cores on a cluster node and all nodes in the cluster for parallel processing. File block and task container sizes are not optimal and need to be tuned. Your task is to understand the performance characteristics of your system for this workload and propose improvements to the setup. Provide your resulting performance numbers and interpret them. For observability of your cluster's resources, please refer to the Hadoop and monitoring tutorials. For details of the Hadoop configuration, see:

- [core-site.xml](https://apache.github.io/hadoop/hadoop-project-dist/hadoop-common/core-default.xml)
- [hdfs-site.xml](https://apache.github.io/hadoop/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml)
- [mapred-site.xml]()
- [yarn-site.xml](https://apache.github.io/hadoop/hadoop-yarn/hadoop-yarn-common/yarn-default.xml)

#### Adjusting the File Block Size

To get started, you may study the performance impact of the HDFS file block size. Add the file to HDFS again, but this time use block sizes of 32 and 8 MB:

```
hadoop fs -D dfs.replication=1 -D dfs.block.size=33554432 -copyFromLocal data_file /WordCount/input/128mb_block4_rep1
```

and re-run the program:

```
# Delete output from the previous run 
hdfs dfs -rm -r /WordCount/output
# Run wordcount for file with 32MB blocksize
time hadoop jar WordCount.jar WordCount /WordCount/input/128mb_block4_rep1 /WordCount/output
```

Report the runtimes on your cluster in a CSV file `task01_blocksizes.csv` as below: 

| Number of Blocks | Runtime (s) |
|------------------|-------------|
| 1 |  |
| 4 |  |
| 16 |  |

  
Answer the following questions in a text file `task01_blocksizes.txt`. To support your answers, add screenshots of the Hadoop and Grafana web UIs with the names  
`task01_blocksizes_hadoop.jpg` and `task01_blocksizes_grafana.jpg`

+ How does the task startup time change?
+ How many task containers are running and on which nodes?
+ Where do the Mapper tasks run, and where do the Reduce tasks run?

Going forward, proceed with the best-performing block size configuration.

#### Adjusting the Task Container Size

Another performance-relevant knob is the memory allocated per task container.  
 Change the YARN configuration, so we get smaller containers: Open `/opt/hadoop/etc/hadoop/yarn-site.xml` and change this configuration.

```
<property>
    <name>yarn.scheduler.minimum-allocation-mb</name>
    <value>2048</value>
</property>
```

Restart YARN with:

```
/opt/hadoop/sbin/stop-yarn.sh
/opt/hadoop/sbin/start-yarn.sh
```

Report the runtimes on your cluster in a CSV `task01_containersizes.csv` as below:

| Container Size (MB) | Runtime (s) |
|---------------------|-------------|
| 8192 |  |
| 2048 |  |
| ... |  |

  
Answer the following questions in a text file `task01_containersizes.txt`. To support your answers, add screenshots of the Hadoop and Grafana web UIs with the names  
`task01_containersizes_hadoop.jpg` and `task01_containersizes_grafana.jpg`

+ How many task containers are running and on which nodes?
+ Where do the Mapper tasks run, and where do the Reduce tasks run?

#### Bonus

For the first task, you can collect one bonus point each by providing the following for a 1 GB sized text file (you may concatenate the original 128 MB file another 3 times to get to 1 GB):  
\- Identify the best-performing overall configuration of block sizes and container sizes. Back your result with runtime results in a CSV called `task01_bonus01.csv`. Explain why this is the best configuration.  
\- Identify one more performance-relenant knob from the Hadoop configuration files and provide documentation on how it affects the performance of the program in a CSV file named `task01_bonus02.csv` .

#### Submission

Submit the following files packaged into a zip file named `task01.zip`:  
\- `task01_blocksizes.csv`  
\- `task01_blocksizes.txt`  
\- `task01_blocksizes_hadoop.jpg`  
\- `task01_blocksizes_grafana.jpg`  
\- `task01_containersizes.csv`  
\- `task01_containersizes.txt`  
\- `task01_containersizes_hadoop.jpg`  
\- `task01_containersizes_grafana.jpg`   
\- optional: `task01_bonus01.csv`   
\- optional: `task01_bonus02.csv`

#### Presentation

For each group, one student representative demonstrates their Hadoop setup in action for selected configuration settings. This includes (re)running the MapReduce program and showing and interpreting the effects of the configuration via the Hadoop and Grafana web UIs.  
Each lab session, we rotate and document the students representing the groups so every student gets her/his turn in the course of the semester.
