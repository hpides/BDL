#! /bin/bash


MASTERNODE=node01


getProjectDirectory () {
	PROJECT_DIR=$( cd -- "$( dirname $( dirname -- "${BASH_SOURCE[0]}" ))" &> /dev/null && pwd )
}

piSCP () {
	scp -qrp -o LogLevel=QUIET $1 pi@$MASTERNODE:$2
}

piSSH () {
	ssh pi@$MASTERNODE $@
}

copyFilesToCluster () {
	piSCP $PROJECT_DIR/mapReduceWordCount/WordCount.java \~
	piSCP $PROJECT_DIR/mapReduceWordCount/file\* \~
	piSCP $PROJECT_DIR/scripts/runOnCluster/runWordCountExample.sh \~
}

checkIfFolderForWordCountIsMissing () {
	! piSSH hadoop fs -ls / | grep -q /WordCount
}

createFoldersForWordCount () {
	piSSH hdfs dfs -mkdir -p /WordCount
	piSSH hdfs dfs -mkdir -p /WordCount/input
}

copyWordCountToCluster () {
	copyFilesToCluster
}

runWordCount () {
	piSSH ./runWordCountExample.sh
}

main () {
	getProjectDirectory
	createFoldersForWordCount
	copyWordCountToCluster
	runWordCount
}

main

