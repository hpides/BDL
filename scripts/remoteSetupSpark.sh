#! /bin/bash


NODE=node01


getProjectDirectory () {
	PROJECT_DIR=$( cd -- "$( dirname $( dirname -- "${BASH_SOURCE[0]}" ))" &> /dev/null && pwd )
}

piSCP () {
	scp -qrp -o LogLevel=QUIET $1 pi@$NODE:$2
}

piSSH () {
	ssh pi@$NODE $@
}

copySetupScriptToCluster () {
	piSCP $PROJECT_DIR/scripts/runOnCluster/setupSpark.sh \~
}

runSetupScript () {
	piSSH ./setupSpark.sh
}

main () {
	getProjectDirectory
	for nodeItr in {5..1}; do
		NODE="node0$nodeItr"
		echo "***************************"
		echo "* Setting up $NODE"
		echo "***************************"
		copySetupScriptToCluster
		runSetupScript 1> /dev/null &
	done
}

main

