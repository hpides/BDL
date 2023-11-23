#! /bin/bash


HEADNODE=node01


getProjectDirectory () {
	PROJECT_DIR=$( cd -- "$( dirname $( dirname -- "${BASH_SOURCE[0]}" ))" &> /dev/null && pwd )
}

piSCP () {
	scp -qrp -o LogLevel=QUIET $1 pi@$HEADNODE:$2
}

piSSH () {
	ssh pi@$HEADNODE $@
}

copyStartScriptToCluster () {
	piSCP $PROJECT_DIR/scripts/runOnCluster/startHadoop.sh \~
}

startHadoop () {
	piSSH ./startHadoop.sh
}

main () {
	getProjectDirectory
	copyStartScriptToCluster
	startHadoop
}

main

