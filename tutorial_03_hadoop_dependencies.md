## Hadoop Setup

Now we install the dependencies required by Hadoop. When not otherwise stated all instructions have to be executed on all nodes.

### Prerequisites

You have already done the *Build a HCP-Cluster with Raspberry Pis* tutorial and have a cluster of five nodes at hand, which can connect to each other with ssh passwordless.

### Java Installation

First download `jdk-8u371-linux-aarch64.tar.gz` from the internet. Use Google for it.
Next copy the `jdk-8u371-linux-aarch64.tar.gz` to the Pi and ssh into the Pi. Extract the JDK into the folder `/opt/java`.

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
