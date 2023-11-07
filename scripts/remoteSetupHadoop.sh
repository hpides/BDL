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
	piSCP $SCRIPT_DIR/runOnCluster/setupHadoop.sh \~
	piSCP $SCRIPT_DIR/../dependencies/jdk-8u371-linux-aarch64.tar.gz \~
	piSCP $SCRIPT_DIR/../dependencies/hadoop-3.3.6.tar.gz \~
}

runSetupScriptOnClusterNode () {
	piSSH ./setupHadoop.sh
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

