#! /bin/bash


MASTERNODE=node01


getScriptDirectory () {
	SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
}

piSCP () {
	scp -qrp -o LogLevel=QUIET $1 pi@$MASTERNODE:$2
}

piSSH () {
	ssh pi@$MASTERNODE $@
}

copyFilesToCluster () {
	piSCP $SCRIPT_DIR/../examples/mapReduceWordCount/WordCount.java \~
	piSCP $SCRIPT_DIR/../examples/mapReduceWordCount/file\* \~
	piSCP $SCRIPT_DIR/runOnCluster/runMapReduceWordCountExample.sh \~
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
	piSSH ./runMapReduceWordCountExample.sh
}

main () {
	getScriptDirectory
	createFoldersForWordCount
	copyWordCountToCluster
	runWordCount
}

main

