#! /bin/bash


# Usage: Has to be run in the master node!


checkIfHadoopIsStopped () {
	! jps | grep -qP NameNode ||
	! jps | grep -qP SecondaryNameNode ||
	! jps | grep -qP ResourceManager ||
	! jps | grep -qP JobHistoryServer
}

startHadoop () {
	echo Checking if Hadoop runs
	if checkIfHadoopIsStopped; then
		./startHadoop.sh
		wait
	fi
}

checkIfOutputDirectoryInHDFSExists () {
	hadoop fs -ls /WordCount | grep -q /WordCount/output
}

removeOutputDirectoryInHDFS () {
	hadoop fs -rm -r /WordCount/output
}

prepareHDFS () {
	echo Preparing distributed filesystem
	if checkIfOutputDirectoryInHDFSExists; then
		removeOutputDirectoryInHDFS
	fi
}

createInputFileInHFDS () {
	echo "The cat is red The dog is blue A mouse is running A human is going to sleep The cat is sleeping The dog is going to sleep
A mouse is running A human is running The cat is blue A dog is blue A mouse is sleeping A human is red A cat is going to sleep The dog is red A mouse is blue A human is going to sleep
A cat is running The dog is sleeping A mouse is blue A human is running The cat is blue A dog is blue A mouse is going to sleep A human is red A cat is going to sleep The dog is running A mouse is red A human is sleeping The cat is red The dog is blue
A mouse is running A human is going to sleep The cat is sleeping The dog is going to sleep A mouse is running
A human is running The cat is blue A dog is blue A mouse is sleeping A human is red
A cat is going to sleep The dog is red A mouse is blue A human is going to sleep A cat is running The dog is sleeping A mouse is blue A human is running The cat is blue
A dog is blue A mouse is going to sleep A human is red A cat is going to sleep The dog is running
A mouse is red
A human is sleeping The cat is red The dog is blue A mouse is running A human is going to sleep The cat is sleeping The dog is going to sleep A mouse is running
A human is running The cat is blue A dog is blue A mouse is sleeping A human is red
A cat is going to sleep The dog is red A mouse is blue A human is going to sleep
A cat is running The dog is sleeping A mouse is blue A human is running The cat is blue" > file01

	hadoop fs -copyFromLocal -f file* /WordCount/input
	rm file*
}

compileWordCount () {
	echo Compiling Word Count Example
	hadoop com.sun.tools.javac.Main WordCount.java
	jar cf WordCount.jar WordCount*.class
	rm 'WordCount$IntSumReducer.class' 'WordCount$TokenizerMapper.class' WordCount.class
}

runWordCount () {
	echo
	echo "***********************************"
	echo "* The Word Count Runs"
	echo "***********************************"
	hadoop jar WordCount.jar WordCount /WordCount/input /WordCount/output
}

printResult () {
	echo
	echo "***********************************"
	echo "* The Word Count Result"
	echo "***********************************"
	hadoop fs -cat /WordCount/output/part-r-00000
}

main () {
	startHadoop
	prepareHDFS
	createInputFileInHFDS
	compileWordCount
	runWordCount
	printResult
}

main

