#! /bin/bash


# Usage: Has to be run on head node!


checkIfHeadNode () {
	[[ "$HOSTNAME" = "node01" ]]
}

checkIfSparkIsStopped () {
	! jps | grep -qP Master
}

startHadoop () {
	./startHadoop.sh
}

startSparkCluster () {
	/opt/spark/sbin/start-connect-server.sh --packages org.apache.spark:spark-connect_2.12:$SPARK_VERSION
	/opt/spark/sbin/start-history-server.sh
	/opt/spark/sbin/start-all.sh
}

printSparkVersionText () {
	spark-shell --version
	echo "You can access the Web UI via http://node01:8080"
	echo "and the Histery Server UI via http://node01:18080"
}

main () {
	if checkIfHeadNode; then
		startHadoop
		if checkIfSparkIsStopped; then
			startSparkCluster
		fi
		printSparkVersionText
	fi
}

main

