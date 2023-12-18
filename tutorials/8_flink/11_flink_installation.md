## Flink

You need to already have a cluster of five nodes running and the Hadoop tutorial done. If not otherwise noted all commands have to be run on all nodes.

### Flink Installation
ssh into the node and run the following commands.

```
sudo rm -rf /opt/flink*
wget -q --progress=bar:force --show-progress https://archive.apache.org/dist/flink/flink-1.8.3/flink-1.8.3-bin-scala_2.12.tgz
sudo tar -xzf flink-1.8.3-bin-scala_2.12.tgz
rm flink-1.8.3-bin-scala_2.12.tgz
sudo mv flink-1.8.3 /opt/flink
sudo chown pi:hadoop -R /opt/flink
```

Add the following environment variables to `~/.environment_variables` and `source ~/.environment_variables` afterwards.

.environment_variables:
```bash
[...]

export FLINK_HOME=/opt/flink
export PATH=$PATH:$FLINK_HOME/bin
export HADOOP_CLASSPATH=`hadoop classpath`:$HADOOP_CLASSPATH

export JAVA_TOOL_OPTIONS="-XX:+UnlockExperimentalVMOptions -XX:+UseG1GC"
```

```bash
source ~/.environment_variables
```

Verify the Flink installation with `flink --version`

```bash
flink --version

Version: 1.8.3, [...]
```
