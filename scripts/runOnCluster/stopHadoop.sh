#! /bin/bash


# Usage: Has to be run on the master node!

stopHistoryServer () {
	echo "Stopping historyserver"
	mapred --daemon stop historyserver
}

stopYARN () {
	/opt/hadoop/sbin/stop-yarn.sh
}

stopHDFS () {
	/opt/hadoop/sbin/stop-dfs.sh
}

main () {
	stopHistoryServer
	stopYARN
	stopHDFS
}

main

