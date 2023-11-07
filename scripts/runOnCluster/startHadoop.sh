#! /bin/bash


# Usage: Has to be run on master node!


checkIfHDFSIsStopped () {
	! jps | grep -qP NameNode ||
	! jps | grep -qP SecondaryNameNode
}

startHDFS () {
	/opt/hadoop/sbin/start-dfs.sh
}

checkIfResourceManagerIsStopped () {
	! jps | grep -qP ResourceManager
}

startYARN () {
	/opt/hadoop/sbin/start-yarn.sh
}

checkIfHistoryServerIsStopped () {
	! jps | grep -qP JobHistoryServer
}

startHistoryServer () {
	echo "Starting historyserver"
	mapred --daemon start historyserver
}

checkIfHadoopIsMissingDatanodes () {
	! hdfs dfsadmin -report | grep -q "Live datanodes (4)"
}

main () {
	if checkIfHDFSIsStopped; then
		startHDFS
	fi
	if checkIfResourceManagerIsStopped; then
		startYARN
	fi
	if checkIfHistoryServerIsStopped; then
		startHistoryServer
	fi
	if checkIfHadoopIsMissingDatanodes; then
		echo "WARNING: Hadoop is missing some datanodes. You probably formatted the namenode folder twice."
	fi
}

main

