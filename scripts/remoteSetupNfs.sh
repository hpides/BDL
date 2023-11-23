#! /bin/bash


getProjectDirectory () {
	PROJECT_DIR=$( cd -- "$( dirname $( dirname -- "${BASH_SOURCE[0]}" ))" &> /dev/null && pwd )
}

piSCP () {
	scp -qrp -o LogLevel=QUIET $1 pi@$NODE:$2
}

piSSH () {
	ssh pi@$NODE $@
}

copySetupFilesToCluster () {
	for keyItr in {1..5}; do
		NODE=node0$keyItr
		piSCP $PROJECT_DIR/scripts/runOnCluster/setupNFS.sh \~
	done
}

runSetupScriptsInParallel () {
	for keyItr in {1..5}; do
		NODE=node0$keyItr
		piSSH ./setupNFS.sh
	done
}

waitForAllNodesToFinish () {
	wait
}

main () {
	getProjectDirectory
	copySetupFilesToCluster
	runSetupScriptsInParallel
	waitForAllNodesToFinish
}

main

