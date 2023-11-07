#! /bin/bash


HEADNODE=node01


getScriptDirectory () {
	SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
}

piSCP () {
	scp -qrp -o LogLevel=QUIET $1 pi@$HEADNODE:$2
}

piSSH () {
	ssh pi@$HEADNODE $@
}

copyStartScriptToCluster () {
	piSCP $SCRIPT_DIR/runOnCluster/startHadoop.sh \~
}

startHadoop () {
	piSSH ./startHadoop.sh
}

main () {
	getScriptDirectory
	copyStartScriptToCluster
	startHadoop
}

main

