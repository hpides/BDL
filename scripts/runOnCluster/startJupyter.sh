#! /bin/bash


# Usage: Has to be run on head node!


checkIfHeadNode () {
	[[ "$HOSTNAME" = "node01" ]]
}

startSparkCluster () {
	./startSpark.sh
}

startJupyter () {
	source .venv/word_count/bin/activate
	jupyter notebook --no-browser --port=8888 --ip=node01
}

main () {
	if checkIfHeadNode; then
		startSparkCluster
		startJupyter
	fi
}

main

