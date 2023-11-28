#! /bin/bash


# Usage: Has to be run on head node!


checkIfHeadNode () {
	[[ $HOSTNAME -eq node01 ]]
}

stopSparkCluster () {
	/opt/spark/sbin/stop-history-server.sh
	/opt/spark/sbin/stop-connect-server.sh
	/opt/spark/sbin/stop-all.sh
}

main () {
	if checkIfHeadNode; then
		stopSparkCluster
	fi
}

main

