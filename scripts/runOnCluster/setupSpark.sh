#! /bin/bash


# Usage: Has to be run on head node!


installSpark () {
	sudo rm -rf /opt/spark* /tmp/spark*
	sudo wget -q --progress=bar:force --show-progress https://dlcdn.apache.org/spark/spark-3.4.1/spark-3.4.1-bin-hadoop3.tgz
	sudo tar -xzf spark-3.4.1-bin-hadoop3.tgz
	sudo rm spark-3.4.1-bin-hadoop3.tgz
	sudo mv spark-3.4.1-bin-hadoop3 /opt/spark
	sudo chown pi:hadoop -R /opt/spark
	mkdir /tmp/spark-events
}

checkIfSparkHomeIsMissingExport () {
	! grep -q "export SPARK_HOME=/opt/spark" ~/.environment_variables
}

addSparkEnvironmentVariables () {
	sudo tee -a ~/.environment_variables << ENVIRONMENT_VARIABLES
export SPARK_HOME=/opt/spark
export SPARK_MASTER_HOST=node01
export PATH=\$PATH:\$SPARK_HOME/bin
export PATH=\$PATH:\$SPARK_HOME/sbin
export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop
export LD_LIBRARY_PATH=\$HADOOP_HOME/lib/native:\$LD_LIBRARY_PATH
ENVIRONMENT_VARIABLES
	source ~/.bashrc
}

configureSpark () {
	sudo tee $SPARK_HOME/conf/spark-defaults.conf << SPARK_DEFAULTS_CONF
spark.master yarn
spark.driver.memory 512m
spark.yarn.am.memory 512m
spark.executor.memory 512m
spark.executor.cores 4
spark.eventLog.enabled true
spark.eventLog.dir file:///tmp/spark-events
spark.history.fs.logDirectory file:///tmp/spark-events
SPARK_DEFAULTS_CONF
}

addWorkers () {
	cp /opt/spark/conf/workers.template /opt/spark/conf/workers
	echo node02 > /opt/spark/conf/workers
	for workerItr in {3..5}; do
		echo node0$workerItr >> /opt/spark/conf/workers
	done
}

checkIfHeadNode () {
	[[ "$HOSTNAME" = "node01" ]]
}

startSparkCluster () {
	/opt/spark/sbin/start-connect-server.sh --packages org.apache.spark:spark-connect_2.12:3.4.1
	/opt/spark/sbin/start-history-server.sh
	/opt/spark/sbin/start-all.sh
}

printSparkVersionText () {
	spark-shell --version
	echo "You can access the Web UI via http://node01:8080"
	echo "and the Histery Server UI via http://node01:18080"
}

checkIfSparkHomePythonPathIsMissingExport () {
	! grep -q "export PYTHONPATH" ~/.environment_variables
}

addPySparkEnvironmentVariables () {
	sudo tee -a ~/.environment_variables << ENVIRONMENT_VARIABLES
export PYTHONPATH=\$(ZIPS=("\$SPARK_HOME"/python/lib/*.zip); IFS=:; echo "\${ZIPS[*]}"):\$PYTHONPATH
ENVIRONMENT_VARIABLES
	source ~/.bashrc
}

installPySpark () {
	if checkIfSparkHomePythonPathIsMissingExport; then
		addPySparkEnvironmentVariables
	fi
	sudo apt update
	sudo apt --yes upgrade
	sudo apt --yes install python3-pip python3-venv
	python3 -m venv .venv/word_count
}

installJupyter () {
	source .venv/word_count/bin/activate
	pip install pyspark jupyter hdfs pandas sklearn seaborn
	source .venv/word_count/bin/activate
}

startJupyterNotebook () {
	jupyter notebook --no-browser --port=8888 --ip=node01
}

main () {
	installSpark
	if checkIfSparkHomeIsMissingExport; then
		addSparkEnvironmentVariables
	fi
	configureSpark
	addWorkers
	installPySpark
	installJupyter
	if checkIfHeadNode; then
		startSparkCluster
		printSparkVersionText
		startJupyterNotebook
	fi
}

main

