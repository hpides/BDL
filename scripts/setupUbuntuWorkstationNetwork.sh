#! /bin/bash


# Usage: Either write the Ethernet interfaces here or provide them as arguments.
# When the internet he first argument is the Pi cluster connection & the second argument is the
# internet connection.
#
# Example:
#	 ./setupWorkstationNetwork.sh eth0 eth1
#
# Get the Ethernet devices with
# ifconfig -a


checkIfNetstatIsMissing () {
	! command -v netstat &> /dev/null
}

aptGetNetTools () {
	sudo apt install net-tools
}

installNetstat () {
	if checkIfNetstatIsMissing; then
		aptGetNetTools
	fi
}

checkIfThereAreArguments () {
	! [ "$#" -eq 0 ]
}

checkIfThereMoreThenTwoArguments () {
	! [ "$#" -lt 2 ]
}

checkIfThereAreTwoArguments () {
	checkIfThereAreArguments $@ && checkIfThereMoreThenTwoArguments $@
}

setCLUSTERCONNECTION () {
	CLUSTERCONNECTION=$1
}

setINTERNETCONNECTION () {
	INTERNETCONNECTION=$1
}

setInterfaceNamesAutomatically () {
	echo "Setting up interface names automatically"
	CLUSTERCONNECTION=$(ip addr | grep "state UP" | tail -1 | sed -e 's/.*: \(.*\): .*/\1/')
	INTERNETCONNECTION=$(netstat -rn | grep UG | head -n 1 | awk '{print $NF}')
}

setInterfaceNames () {
	if checkIfThereAreTwoArguments $@; then
		setCLUSTERCONNECTION $1
		setINTERNETCONNECTION $2
	else
		setInterfaceNamesAutomatically
	fi
}

checkIfPiClusterConnectionExists () {
	nmcli con show | grep -q Pi_Cluster
}

deletePiClusterConnection () {
	sudo nmcli con del "Pi_Cluster"
}

createPiClusterConnection () {
	sudo nmcli con add type ethernet con-name "Pi_Cluster" ifname $CLUSTERCONNECTION ipv4.addresses 10.0.0.10/24 ipv4.method manual
}

setupStaticIp () {
	echo "Setting up static IP"
	if checkIfPiClusterConnectionExists; then
		deletePiClusterConnection
	fi
	createPiClusterConnection
}

enablePacketForwarding () {
	echo "Enabling packet forwarding"
	sudo sysctl net.ipv4.ip_forward=1
	sudo sysctl net.ipv6.conf.default.forwarding=1
	sudo sysctl net.ipv6.conf.all.forwarding=1
}

setUpNat () {
	echo "Setting up NAT"
	sudo iptables -t nat -A POSTROUTING -o $INTERNETCONNECTION -j MASQUERADE
	sudo iptables -A FORWARD -i $INTERNETCONNECTION -o $CLUSTERCONNECTION -m state --state RELATED,ESTABLISHED -j ACCEPT
	sudo iptables -A FORWARD -i $CLUSTERCONNECTION -o $INTERNETCONNECTION -j ACCEPT
}

getInternetIntoThePis () {
	enablePacketForwarding
	setUpNat
}

checkIfHostsFileIsMissingHostnames () {
	! grep -q "Pi Cluster" /etc/hosts
}

writeHostnamesIntoHostsFile () {
	echo "" | sudo tee -a /etc/hosts
	echo "# Pi Cluster" | sudo tee -a /etc/hosts
	for hostItr in {1..5}; do
		echo "10.0.0.$hostItr node0$hostItr" | sudo tee -a /etc/hosts
	done
}

removeOldSSHKeys () {
	for keyItr in {1..5}; do
		ssh-keygen -f ~/.ssh/known_hosts -R node0$keyItr
	done
}

checkIfWeHaveAnSSHKey () {
	[[ $(ls -A ~/.ssh/id_*) ]]
}

createNewSSHKey () {
	ssh-keygen -q -t ed25519 -N '' <<< $'\ny' >/dev/null 2>&1
}

checkIfKnownHostsFileExists () {
	[ -f "~/.ssh/know_hosts" ]
}

checkIfNodeHostnameIsInKnownHosts () {
	grep -q "node0$1" ~/.ssh/known_hosts
}

checkIfOldNodeKeyIsInKnownHosts () {
	checkIfKnownHostsFileExists && checkIfNodeHostnameIsInKnownHosts $1
}

removeOldNodeKeyFromKnownHosts () {
	ssh-keygen -R "node0$1"
}

checkIfWeCanPingPi () {
	ping -c 1 -w 1 node0$1 | grep -q "1 received"
}

copyPublicKeysToPIs () {
	if checkIfOldNodeKeyIsInKnownHosts $1; then
		removeOldNodeKeyFromKnownHosts $1
	fi

	sshpass -p raspberry ssh-copy-id -o ConnectTimeout=2 -o StrictHostKeyChecking=accept-new pi@node0$1
}

setupPasswordlessSSH () {
	echo "Setting up passwordless SSH"
	if ! checkIfWeHaveAnSSHKey; then
		echo "Creating new SSH key"
		createNewSSHKey
	fi

	for keyItr in {1..5}; do
		if checkIfWeCanPingPi $keyItr; then
			copyPublicKeysToPIs $keyItr
		else
			echo Cannot connect to node0$keyItr
		fi
	done
}

printSettings () {
	echo
	echo "Pi Cluster Interface:"
	echo "*********************"
	echo $CLUSTERCONNECTION

	echo
	echo "Internet Interface:"
	echo "*********************"
	echo $INTERNETCONNECTION

	echo
	echo "Packet Forwarding Settings:"
	echo "*****************************"
	sudo sysctl -a | grep "net.ipv4.ip_forward =\|net.ipv6.conf.default.forwarding =\|net.ipv6.conf.all.forwarding ="

	echo
	echo "NAT Settings:"
	echo "**********************"
	netstat -rn | grep " $CLUSTERCONNECTION"
}

main () {
	installNetstat
	setInterfaceNames $@
	setupStaticIp
	getInternetIntoThePis
	if checkIfHostsFileIsMissingHostnames; then
		writeHostnamesIntoHostsFile
	fi
	removeOldSSHKeys
	setupPasswordlessSSH
	printSettings
}

main

