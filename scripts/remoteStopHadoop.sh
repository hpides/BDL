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

copyStopScriptToCluster () {
	piSCP $SCRIPT_DIR/runOnCluster/stopHadoop.sh \~
}

stopHadoop () {
	piSSH ./stopHadoop.sh
}

main () {
	getScriptDirectory
	copyStopScriptToCluster
	stopHadoop
}

main

