## Hadoop Setup

Now we configure the Hadoop on our Pi cluster with one Namenode and 4 Datanodes. When not otherwise stated all instructions have to be executed on all nodes.

### Hadoop Environment Variables

Add the Hadoop environment variables by typing `sudo nano ~/.environment_variables` and putting the lines below to the bottom of the file. Those changes get effective after `source ~/.bashrc` is executed.

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

Finally we have to configure Hadoop. Therefor we change the configuration files as follows.

```bash
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

```bash
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

```bash
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

```bash
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

```bash
sudo nano /opt/hadoop/etc/hadoop/hadoop-env.sh
```

and adding

```
export JAVA_HOME=/opt/java/jdk1.8.0_371
```

On the Namenode (node01) only, create a `workers` file in the `/opt/hadoop/etc/hadoop/` directory and add the 4 other nodes, one per line.

workers:

```
node02
node03
node04
node05
```

Finally, you can initialize the HDFS on the Namenode with

```bash
hdfs namenode -format
```
