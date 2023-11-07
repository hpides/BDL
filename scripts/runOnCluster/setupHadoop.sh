#! /bin/bash


# Usage: Has to be run on a cluster node!


updatePackageManager () {
	sudo apt update
	sudo apt --yes upgrade
}

checkIfWeHaveNoSSHKey () {
	[[ ! $(ls -A ~/.ssh/id_*) ]]
}

createNewSSHKey () {
	ssh-keygen -q -t ed25519 -N '' <<< \$'\ny' >/dev/null 2>&1
}

copyPublicKeysToPIs () {
	for keyItr in {1..5}; do
		sshpass -p raspberry ssh-copy-id -o ConnectTimeout=2 -o StrictHostKeyChecking=accept-new pi@node0$keyItr
	done
}

setupPasswordlessSSH () {
	if checkIfWeHaveNoSSHKey; then
		createNewSSHKey
	fi

	copyPublicKeysToPIs
}

checkIfEnvironmentVariablesFileIsMissingInBashrc () {
	! grep -q ". \~/.environment_variables" ~/.bashrc
}

createEnvironmentVariablesFile () {
	echo "# Script that is always run by .bashrc to set up environment even for ssh commands" > ~/.environment_variables
	echo "" >> ~/.environment_variables
	if checkIfEnvironmentVariablesFileIsMissingInBashrc; then
		sed -i ':a;N;$!ba; s|# If not running interactively, don|. ~/.environment_variables\n\n# If not running interactively, don|g' ~/.bashrc
	fi
}

installSshpass () {
	sudo apt --yes install sshpass
}

deleteOldJDK () {
	sudo rm -r /opt/java
}

unpackJDKToOptJava () {
	sudo mkdir -p /opt/java
	sudo tar xzf jdk-8u371-linux-aarch64.tar.gz --directory /opt/java
	sudo rm jdk-8u371-linux-aarch64.tar.gz
}

exportJDKEnvironemtVariables () {
	tee -a ~/.environment_variables << EOF
export PATH=\$PATH:/opt/java/jdk1.8.0_371/bin
export JAVA_HOME=/opt/java/jdk1.8.0_371
EOF
}

installOpenJDK () {
	deleteOldJDK
	unpackJDKToOptJava
	exportJDKEnvironemtVariables
}

checkIfHadoopGroupDoesNotExist () {
	! getent group hadoop | grep -wq "hadoop"
}

createHadoopGroup () {
	sudo addgroup hadoop
}

checkIfUserPIIsNotInGroupHadoop () {
	! getent group hadoop | grep -wq "pi"
}

addPIToHadoopGroup () {
	sudo adduser pi hadoop
}

deleteAllHadoopFolders () {
	sudo rm -r /tmp/hadoop*
	sudo rm -r /opt/hadoop*
}

createHadoopTmpFolders () {
	sudo mkdir /opt/hadoop_tmp/
	sudo mkdir /opt/hadoop_tmp/hdfs
	sudo chown pi:hadoop -R /opt/hadoop_tmp
	sudo chown pi:hadoop -R /opt/hadoop_tmp/hdfs
}

unpackHadoop () {
	sudo tar xzf hadoop-3.3.6.tar.gz --directory /opt/
	sudo mv /opt/hadoop-3.3.6 /opt/hadoop
	sudo rm hadoop-3.3.6.tar.gz
	sudo chown pi:hadoop -R /opt/hadoop
}

exportHadoopEnvironmentVariables () {
	tee -a ~/.environment_variables << EOF
export HADOOP_HOME=/opt/hadoop
export HADOOP_INSTALL=\$HADOOP_HOME
export YARN_HOME=\$HADOOP_HOME
export PATH=\$PATH:\$HADOOP_INSTALL/bin
export PATH=\$PATH:\$HADOOP_INSTALL/sbin
export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native
export HADOOP_OPTS=-Djava.library.path=\$HADOOP_HOME/lib
export HADOOP_USER_NAME=pi
export HADOOP_CLASSPATH=\$JAVA_HOME/lib/tools.jar
EOF
}

configureCoreSiteXML () {
	sed -i ':a;N;$!ba; s|\n<configuration.*<\/configuration>||g' /opt/hadoop/etc/hadoop/core-site.xml
	tee -a /opt/hadoop/etc/hadoop/core-site.xml << EOCAT
<configuration>
	<property>
		<name>fs.default.name</name>
		<value>hdfs://node01:9000</value>
	</property>
	<property>
		<name>fs.default.FS</name>
		<value>hdfs://node01:9000</value>
	</property>
</configuration>
EOCAT
}

configureHdfsSiteXML () {
	sed -i ':a;N;$!ba; s|\n<configuration.*<\/configuration>||g' /opt/hadoop/etc/hadoop/hdfs-site.xml
	tee -a /opt/hadoop/etc/hadoop/hdfs-site.xml << EOCAT
<configuration>
	<property>
		<name>dfs.datanode.data.dir</name>
		<value>/opt/hadoop_tmp/hdfs/datanode</value>
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
EOCAT
}

configureYarnSiteXML () {
	sed -i ':a;N;$!ba; s|\n<configuration.*<\/configuration>||g' /opt/hadoop/etc/hadoop/yarn-site.xml
	tee -a /opt/hadoop/etc/hadoop/yarn-site.xml << EOCAT
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
EOCAT
}

configureMapredSiteXML () {
	sed -i ':a;N;$!ba; s|\n<configuration.*<\/configuration>||g' /opt/hadoop/etc/hadoop/mapred-site.xml
	tee -a /opt/hadoop/etc/hadoop/mapred-site.xml << EOCAT
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
		<value>HADOOP_MAPRED_HOME=\${HADOOP_HOME}</value>
	</property>
	<property>
		<name>mapreduce.map.env</name>
		<value>HADOOP_MAPRED_HOME=\${HADOOP_HOME}</value>
	</property>
	<property>
		<name>mapreduce.reduce.env</name>
		<value>HADOOP_MAPRED_HOME=\${HADOOP_HOME}</value>
	</property>
</configuration>
EOCAT
}

checkIfJAVAHOMEIsNotInHadoopEnvSH () {
	! grep -Fxq "export JAVA_HOME=$JAVA_HOME" /opt/hadoop/etc/hadoop/hadoop-env.sh
}

configureHadoopEnvSH () {
	echo "export JAVA_HOME=$JAVA_HOME" >> /opt/hadoop/etc/hadoop/hadoop-env.sh
}

checkIfIsMasterNode () {
	[ "$HOSTNAME" = "node01" ]
}

addWorkers () {
	echo node02 > /opt/hadoop/etc/hadoop/workers
	for workerItr in {3..5}; do
		echo node0$workerItr >> /opt/hadoop/etc/hadoop/workers
	done
}

setupMasterNode () {
	sudo mkdir -p /opt/hadoop_tmp/hdfs/namenode
	sudo chown pi:hadoop -R /opt/hadoop_tmp/hdfs/namenode
}

formatNameNode () {
	echo 'Y' | hdfs namenode -format
}

setupWorkerNode () {
	sudo mkdir -p /opt/hadoop_tmp/hdfs/datanode
	sudo chown pi:hadoop -R /opt/hadoop_tmp/hdfs/datanode
}

configureHadoop () {
	configureCoreSiteXML
	configureHdfsSiteXML
	configureYarnSiteXML
	configureMapredSiteXML
	if checkIfJAVAHOMEIsNotInHadoopEnvSH; then
		configureHadoopEnvSH
	fi
	if checkIfIsMasterNode; then
		addWorkers
		setupMasterNode
		formatNameNode
	else
		setupWorkerNode
	fi
}

installHadoop () {
	if checkIfHadoopGroupDoesNotExist; then
		createHadoopGroup
	fi
	if checkIfUserPIIsNotInGroupHadoop; then
		addPIToHadoopGroup
	fi
	deleteAllHadoopFolders
	createHadoopTmpFolders
	unpackHadoop
	exportHadoopEnvironmentVariables
	configureHadoop
}

main () {
	echo "***********************************"
	echo "* Setting up $HOSTNAME"
	echo "***********************************"
	updatePackageManager
	setupPasswordlessSSH
	createEnvironmentVariablesFile
	installSshpass
	installOpenJDK
	installHadoop
}

main

