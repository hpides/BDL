## Hadoop Setup

Now we add the user to the Hadoop group and install the Hadoop files for the Hadoop group on our nodes. When not otherwise stated all instructions have to be executed on all nodes.

### Creating Hadoop Group

First we create a Hadoop group, and then we add pi to the group.

```bash
sudo addgroup hadoop
sudo adduser pi hadoop
```

### Creating Hadoop Folder Structure

Next we create the folder structure for Hadoop and change the permissions.

```bash
# On the namenode (node01)
sudo mkdir /opt/hadoop_tmp/
sudo mkdir /opt/hadoop_tmp/hdfs
sudo mkdir /opt/hadoop_tmp/hdfs/namenode

# On the datanodes (node02-node05)
sudo mkdir /opt/hadoop_tmp/
sudo mkdir /opt/hadoop_tmp/hdfs
sudo mkdir /opt/hadoop_tmp/hdfs/datanode
```

For the Namenode and data nodes we have to create different additional folders.

```bash
# On the namenode (node01)
sudo chown pi:hadoop -R /opt/hadoop_tmp/hdfs/namenode

# On the datanodes (node02-node05)
sudo chown pi:hadoop -R /opt/hadoop_tmp/hdfs/datanode
```

### Hadoop Files

First download `hadoop-3.3.6.tar.gz` from the internet. Use Google to find it.
Next we have to exit from the node to copy the Hadoop package to the node. Afterwards we have to ssh again into the node and extract Hadoop to the `/opt/` folder and change the

```bash
exit
scp [...]/dependencies/hadoop-3.3.6.tar.gz node01:~
ssh pi@node01

sudo tar -xvzf ~/hadoop-3.3.6.tar.gz -C /opt/
sudo mv /opt/hadoop-3.3.6 /opt/hadoop
rm ~/hadoop-3.3.6.tar.gz

sudo chown pi:hadoop -R /opt/hadoop
```
