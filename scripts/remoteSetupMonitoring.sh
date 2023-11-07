#! /bin/bash


getScriptDirectory () {
	SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
}

piSCP () {
	scp -qrp -o LogLevel=QUIET $1 pi@$NODE:$2
}

piSSH () {
	ssh pi@$NODE $@
}

copySetupScriptToClusterNode () {
	piSCP $SCRIPT_DIR/runOnCluster/setupMonitoring.sh \~
}

runSetupScriptOnClusterNode () {
	piSSH ./setupMonitoring.sh
}

main () {
	getScriptDirectory
	for nodeItr in {1..5}; do
		NODE=node0$nodeItr
		echo "***********************************"
		echo "* Setting up $NODE"
		echo "***********************************"
		copySetupScriptToClusterNode
		runSetupScriptOnClusterNode 1> /dev/null &
	done

	wait
}

main

