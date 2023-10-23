## Hadoop Setup

Now we add the user to the hadoop group and install the hadoop files for the hadoop group on our nodes. When not otherwise stated all instructions have to be executed on all nodes.

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
