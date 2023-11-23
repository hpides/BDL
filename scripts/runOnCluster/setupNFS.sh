#! /bin/bash


# Usage: Has to be run on Pi node!


checkIfNfsFolderIsMissing () {
	! [ -d "/mnt/nfs" ]
}

createNfsFolder () {
	sudo mkdir /mnt/nfs
	sudo chown -R pi:pi /mnt/nfs
}

checkIfHeadNode () {
	[[ $HOSTNAME -eq node01 ]]
}

installNfsServer () {
	sudo apt-get update
	sudo apt-get install nfs-kernel-server -y
}

checkIfNfsNode2IsMissingInExports () {
	! grep -q "/mnt/nfs node02(rw,sync,no_subtree_check)" /etc/exports
}

setNfsWorkerNodes () {
	sudo tee -a /etc/exports << EXPORTS
/mnt/nfs node02(rw,sync,no_subtree_check)
/mnt/nfs node03(rw,sync,no_subtree_check)
/mnt/nfs node04(rw,sync,no_subtree_check)
/mnt/nfs node05(rw,sync,no_subtree_check)
EXPORTS
}

addNfsWorkerNodes () {
	if checkIfNfsNode2IsMissingInExports; then
		setNfsWorkerNodes
	fi
}

restartServices () {
	sudo /etc/init.d/rpcbind restart
	sudo /etc/init.d/nfs-kernel-server restart
	sudo exportfs -r
}

mountSharedDirectory () {
	sudo mount node01:/mnt/nfs /mnt/nfs
}

checkIfNfsIsMissingInRclocal () {
	! grep -q "nfs" /etc/rc.local
}

removeExitFromRclocal () {
	sudo sed -i ':a;N;$!ba; s|\nexit 0||g' /etc/rc.local
}

addExitToRclocal () {
	echo 'exit 0' | sudo tee -a /etc/rc.local
}

addHeadNfsStartToRclocal () {
	sudo tee -a /etc/rc.local << EXPORTS
sudo /etc/init.d/rpcbind restart
sudo /etc/init.d/nfs-kernel-server restart
EXPORTS
}

configureNfsStartAtBootForHead () {
	if checkIfNfsIsMissingInRclocal; then
		removeExitFromRclocal
		addHeadNfsStartToRclocal
		addExitToRclocal
	fi
}

addWorkerNfsStartToRclocal () {
	sudo tee -a /etc/rc.local << EXPORTS
sudo /etc/init.d/nfs-common restart
sudo mount node01:/mnt/nfs /mnt/nfs
EXPORTS
}

configureNfsStartAtBootForWorker () {
	if checkIfNfsIsMissingInRclocal; then
		removeExitFromRclocal
		addWorkerNfsStartToRclocal
		addExitToRclocal
	fi
}


main () {
	if checkIfNfsFolderIsMissing; then
		createNfsFolder
	fi
	if checkIfHeadNode; then
		installNfsServer
		addNfsWorkerNodes
	fi
	restartServices
	if checkIfHeadNode; then
		configureNfsStartAtBootForHead
	else
		mountSharedDirectory
		configureNfsStartAtBootForWorker
	fi
}

main

