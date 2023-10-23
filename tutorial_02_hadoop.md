## Hadoop Setup

This setup describes how to setup the Hadoop Distributed Filesystem (HDFS) on a Raspberry PI Cluster with one namenode and 4 datanodes and a simple WordCount MapReduce example. When not otherwise stated all instructions have to be executed on all nodes.

### Prerequisites

You have already done the *Build a HCP-Cluster with Raspberry Pis* tutorial and have a cluster of five nodes at hand, which can connect to each other with ssh passwordless.

### Java Installation

Copy the `jdk-8u371-linux-aarch64.tar.gz` to the Pi and ssh into the Pi. Extract the jdk into the folder `/opt/java`.

```
scp [...]/dependencies/jdk-8u371-linux-aarch64.tar.gz node01:~
ssh pi@node01
sudo mkdir -p /opt/java
sudo tar xzf jdk-8u371-linux-aarch64.tar.gz --directory /opt/java
rm /opt/jdk-8u371-linux-aarch64.tar.gz
```

Finish the java installation by adding `JAVA_HOME` to our `~/.environment_variables` file by typing `sudo nano ~/.environment_variables` and putting the lines below to the bottom of the file. Those changes get effective after `source ~/.bashrc`.

.environment_variables:

```shellscript
export JAVA_HOME=/opt/java/jdk1.8.0_371
export PATH=$PATH:/opt/java/jdk1.8.0_371/bin
```

Verify your JAVA installation.

```
java -version
openjdk version "1.8.0_382"
OpenJDK Runtime Environment (build 1.8.0_382-8u382~b04-2-b04)
OpenJDK 64-Bit Server VM (build 25.382-b04, mixed mode)
```

### Creating Hadoop Group

First we create a hadoop group and then we add pi to the group.

```
sudo addgroup hadoop
sudo adduser pi hadoop
```

### Creating Hadoop Folder Structure

Next we create the folder structure for hadoop and chenge the permissons.

```
sudo mkdir /opt/hadoop_tmp/
sudo mkdir /opt/hadoop_tmp/hdfs

# On the datanodes (node02-node05)
sudo mkdir /opt/hadoop_tmp/
sudo mkdir /opt/hadoop_tmp/hdfs
```

For the namenode and data nodes we have to create different additional folders.

```
# On the namenode (node01)
sudo chown pi:hadoop -R /opt/hadoop_tmp/hdfs/namenode

# On the datanodes (node02-node05)
sudo chown pi:hadoop -R /opt/hadoop_tmp/hdfs/datanode
```

### Hadoop Files

First we have to exit from the node to copy the hadoop package to the node. Afterwards we have to ssh again into the node and extract hadoop to the `/opt/` folder and change the

```
exit
scp [...]/dependencies/hadoop-3.3.6.tar.gz node01:~
ssh pi@node01

sudo tar -xvzf /opt/hadoop-3.3.6.tar.gz -C /opt/
sudo mv /opt/hadoop-3.3.6 /opt/hadoop
rm /opt/hadoop-3.3.6.tar.gz

sudo chown pi:hadoop -R /opt/hadoop
```

### Hadoop Environment Variables

Add the Hadoop environment variables by typing `sudo nano ~/.environment_variables` and putting the lines below to the bottom of the file. Those changes get effective after `source ~/.bashrc`.

.environment_variables:

```
[...]

export HADOOP_HOME=/opt/hadoop
export HADOOP_INSTALL=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export PATH=$PATH:$HADOOP_INSTALL/bin
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"
export HADOOP_USER_NAME="pi"
export HADOOP_CLASSPATH=\$JAVA_HOME/lib/tools.jar
```

### Environment Variables

Finally we have to configure hadoop. Therefore we change the configuration files as follows.

```
sudo nano /opt/hadoop/etc/hadoop/core-site.xml
```

```
<configuration>
    <property>
        <name>fs.default.name</name>
        <value>hdfs://node01:9000/</value>
    </property>
    <property>
        <name>fs.default.FS</name>
        <value>hdfs://node01:9000/</value>
    </property>
</configuration>
```

```
sudo nano /opt/hadoop/etc/hadoop/hdfs-site.xml
```

```
# Configuration to be added:
<configuration>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>[DISK]file:///opt/hadoop_tmp/hdfs/datanode,</value>
        <final>true</final>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/opt/hadoop_tmp/hdfs/namenode</value>
        <final>true</final>
    </property>
    <property>
        <name>dfs.namenode.http-address</name>
        <value>node01:50070</value>
    </property>
    <property>
        <name>dfs.replication</name>
        <value>5</value>
    </property>
</configuration>
```

```
sudo nano /opt/hadoop/etc/hadoop/yarn-site.xml
```

```
# Configuration to be added:
<configuration>
    <property>
        <name>yarn.resourcemanager.resource-tracker.address</name>
        <value>node01:8025</value>
    </property>
    <property>
        <name>yarn.resourcemanager.scheduler.address</name>
        <value>node01:8035</value>
    </property>
    <property>
        <name>yarn.resourcemanager.address</name>
        <value>node01:8050</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
</configuration>
```

```
sudo nano /opt/hadoop/etc/hadoop/mapred-site.xml
```

```
# Configuration to be added:
<configuration>
    <property>
        <name>mapreduce.job.tracker</name>
        <value>node01:5431</value>
    </property>
    <property>
        <name>mapred.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>yarn.app.mapreduce.am.env</name>
        <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
    </property>
    <property>
        <name>mapreduce.map.env</name>
        <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
    </property>
    <property>
        <name>mapreduce.reduce.env</name>
        <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
    </property>
</configuration>
```

Then, you need to add an environment variable to Hadoop by typing

```
sudo nano /opt/hadoop/etc/hadoop/hadoop-env.sh
```

and adding

```
export JAVA_HOME=/opt/java/jdk1.8.0_371
```

On the namenode (node01) only, create a `workers` file in the `/opt/hadoop/etc/hadoop/` directory and add the 4 other nodes, one per line.

workers:

```
node02
node03
node04
node05
```

Finally, you can initialize the hdfs on the namenode with

```
hdfs namenode -format
```

### Word Count Example

First of all we have to start the hadoop. Start the `hdfs` using the script `/opt/hadoop/sbin/start-dfs.sh`. If you did the setup correctly, you should be able to print the dfs report with `hdfs dfsadmin -report`. Please verify, that you have 4 Live Datanodes. Than start the resource manager `/opt/hadoop/sbin/start-yarn.sh`.

```
/opt/hadoop/sbin/start-dfs.sh
hdfs dfsadmin -report
/opt/hadoop/sbin/start-yarn.sh
```

Create input and output directories in `hdfs`.

```
hdfs dfs -mkdir -p /WordCount
hdfs dfs -mkdir -p /WordCount/input
hdfs dfs -mkdir -p /WordCount/output
```

Now we create an example input file `file01` and load it to the input folder of the cluster.

```
echo "The cat is red The dog is blue A mouse is running A human is going to sleep The cat is sleeping The dog is going to sleep
A mouse is running A human is running The cat is blue A dog is blue A mouse is sleeping A human is red A cat is going to sleep The dog is red A mouse is blue A human is going to sleep
A cat is running The dog is sleeping A mouse is blue A human is running The cat is blue A dog is blue A mouse is going to sleep A human is red A cat is going to sleep The dog is running A mouse is red A human is sleeping The cat is red The dog is blue
A mouse is running A human is going to sleep The cat is sleeping The dog is going to sleep A mouse is running
A human is running The cat is blue A dog is blue A mouse is sleeping A human is red
A cat is going to sleep The dog is red A mouse is blue A human is going to sleep A cat is running The dog is sleeping A mouse is blue A human is running The cat is blue
A dog is blue A mouse is going to sleep A human is red A cat is going to sleep The dog is running
A mouse is red
A human is sleeping The cat is red The dog is blue A mouse is running A human is going to sleep The cat is sleeping The dog is going to sleep A mouse is running
A human is running The cat is blue A dog is blue A mouse is sleeping A human is red
A cat is going to sleep The dog is red A mouse is blue A human is going to sleep
A cat is running The dog is sleeping A mouse is blue A human is running The cat is blue" > file01

hdfs dfs -copyFromLocal -f file* /WordCount/input
```

Now we need to write the map reduce program that reads `file01` and counts the words. We save the program in a `WordCount.java` file. We need a Tokenizer that maps the text to separate words and a Reducer that sums the count of each word.

WordCount.java:

```shellscript
import java.io.IOException;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class WordCount {

  public static class TokenizerMapper
       extends Mapper<Object, Text, Text, IntWritable>{

    private final static IntWritable one = new IntWritable(1);
    private Text word = new Text();

    public void map(Object key, Text value, Context context
                    ) throws IOException, InterruptedException {
      StringTokenizer itr = new StringTokenizer(value.toString());
      while (itr.hasMoreTokens()) {
        word.set(itr.nextToken());
        context.write(word, one);
      }
    }
  }

  public static class IntSumReducer
       extends Reducer<Text,IntWritable,Text,IntWritable> {
    private IntWritable result = new IntWritable();

    public void reduce(Text key, Iterable<IntWritable> values,
                       Context context
                       ) throws IOException, InterruptedException {
      int sum = 0;
      for (IntWritable val : values) {
        sum += val.get();
      }
      result.set(sum);
      context.write(key, result);
    }
  }

  public static void main(String[] args) throws Exception {
    Configuration conf = new Configuration();
    Job job = Job.getInstance(conf, "word count");
    job.setJarByClass(WordCount.class);
    job.setMapperClass(TokenizerMapper.class);
    job.setCombinerClass(IntSumReducer.class);
    job.setReducerClass(IntSumReducer.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(IntWritable.class);
    FileInputFormat.addInputPath(job, new Path(args[0]));
    FileOutputFormat.setOutputPath(job, new Path(args[1]));
    System.exit(job.waitForCompletion(true) ? 0 : 1);
  }
}
```

Next we compile our program, run it with hadoop and print the output. When everything went well you should see the counts for each word. When you rerun the program you need to remove the output directory.

```shellscript
hadoop com.sun.tools.javac.Main WordCount.java
jar cf WordCount.jar WordCount*.class
rm 'WordCount\$IntSumReducer.class' 'WordCount\$TokenizerMapper.class' WordCount.class

hdfs dfs -rm -r /WordCount/output
hadoop jar WordCount.jar WordCount /WordCount/input /WordCount/output

hdfs dfs -cat /WordCount/output/part-r-00000
```

To stop hadoop first stop the resource manager and than stop the `hdfs`.

```
/opt/hadoop/sbin/stop-yarn.sh
/opt/hadoop/sbin/stop-yarn.sh
```