## Flink

You need to already have a cluster of five nodes running and the Hadoop tutorial done. If not otherwise noted all commands have to be run on all nodes.

### Java Version
The Flink version we are going to install will need Java 11 (or 17). If not installed yet, follow the following instruction to install Java 11 on each node.
  1. [Download Java 11 - aarch64 version](https://adoptium.net/temurin/releases?version=11)
  2. From your local Downloads directory: scp OpenJDK11U-jdk_aarch64_linux_hotspot_11.0.33.1_1.tar.gz pi@<node01-05>:~/
  3. Per node perform:
  ```
  sudo mkdir -p /opt/java/jdk-11
  sudo tar -xzf OpenJDK11U-jdk_aarch64_linux_hotspot_11.0.33.1_1.tar.gz -C /opt/java/jdk-11 --strip-components=1 --no-same-owner
  /opt/java/jdk-11/bin/java -version
  ```
  The last command should output
  ```
  Picked up JAVA_TOOL_OPTIONS: -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC  
  openjdk version "11.0.33.1" 2026-11-17  
  OpenJDK Runtime Environment Temurin-11.0.33.1+1 (build 11.0.33.1+1)  
  OpenJDK 64-Bit Server VM Temurin-11.0.33.1+1 (build 11.0.33.1+1, mixed mode)
  ```
  Adapt the Java path by adding:
  ```
	nano /opt/flink/conf/config.yaml
	env.java.home: /opt/java/jdk-11
  ```

### Flink Installation
ssh into the node and run the following commands.

```
sudo rm -rf /opt/flink*
wget -q --progress=bar:force --show-progress https://dlcdn.apache.org/flink/flink-2.3.0/flink-2.3.0-bin-scala_2.12.tgz
sudo tar -xzf flink-2.3.0-bin-scala_2.12.tgz
rm flink-2.3.0-bin-scala_2.12.tgz
sudo mv flink-2.3.0 /opt/flink
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

Version: 2.3.0, [...]
```
