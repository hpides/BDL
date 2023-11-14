## Spark Setup

### Prerequisites

You have already done the *Setup Hadoop* tutorial and have a cluster of five nodes with HDFS running. If not otherwise noted all commands have to be run on all nodes.

### Spark Installation
ssh into the node and run the following commands.

```
sudo wget https://dlcdn.apache.org/spark/spark-3.4.1/spark-3.4.1-bin-hadoop3.tgz
sudo tar -xvzf spark-3.4.1-bin-hadoop3.tgz -C /opt/
sudo rm spark-3.4.1-bin-hadoop3.tgz
sudo mv /opt/spark-3.4.1-bin-hadoop3 /opt/spark
sudo chown pi:hadoop -R /opt/spark
mkdir /tmp/spark-events
sudo chown pi:hadoop -R /tmp/spark-events
```

Add the following environment variables to `~/.environment_variables` and `source ~/.environment_variables` afterwards.

.environment_variables:

```bash
[...]

export SPARK_HOME=/opt/spark
export SPARK_MASTER_HOST=node01
export PATH=$PATH:$SPARK_HOME/bin
export PATH=$PATH:$SPARK_HOME/sbin
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native:$LD_LIBRARY_PATH
```

```bash
source ~/.environment_variables
```

Then, you need to add an environment variable to Spark by typing

```bash
sudo vi /opt/spark/sbin/spark-config.sh
```

and adding

```bash
export JAVA_HOME=/opt/java/jdk1.8.0_371
```

Verify the spark installation with `spark-shell --version`

```bash
hduser@node01:/opt $ spark-shell --version
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 3.4.1
      /_/

Using Scala version 2.12.17, OpenJDK 64-Bit Server VM, 1.8.0_382
Branch HEAD
Compiled by user centos on 2023-06-19T23:01:01Z
Revision 6b1ff22dde1ead51cbf370be6e48a802daae58b6
Url https://github.com/apache/spark
Type --help for more information.
```

Under `$SPARK_HOME/conf/` create the file `spark-defaults.conf` and add the following lines

```bash
spark.master yarn
spark.driver.memory 512m
spark.yarn.am.memory 512m
spark.executor.memory 512m
spark.executor.cores 4
spark.eventLog.enabled true
spark.eventLog.dir file:///tmp/spark-events
spark.history.fs.logDirectory file:///tmp/spark-events
```

On the Namenode (node01) only, create a `workers` file in the `/opt/spark/conf/` directory and add all nodes, one per line.

workers:

```
node01
node02
node03
node04
node05
```

Start the Spark cluster by executing the following commands only on the head node.

```bash
/opt/spark/sbin/start-connect-server.sh --packages org.apache.spark:spark-connect_2.12:3.4.1
/opt/spark/sbin/start-history-server.sh
/opt/spark/sbin/start-all.sh
```

You can access the Web UI via http://node01:8080 and the Histery Server UI via http://node01:18080

### Execute Word Count Example

Type `spark-shell` and execute:

```
val textFile = sc.textFile("hdfs://node01:9000/WordCount/input/*")
val counts = textFile.flatMap(line => line.split(" "))
                 .map(word => (word, 1))
                 .reduceByKey(_ + _)
counts.repartition(1).saveAsTextFile("hdfs://node01:9000/second_output_spark")
```
