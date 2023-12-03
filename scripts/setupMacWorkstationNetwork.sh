# Usage: Either let the script try to identify the interfaces automatically or provide
# them as script inputs.
# When not providing arguments the interfaces are selected automatically. Make sure
# that you keep the original name of the USB LAN interface, i.e. 'USB 10/100/1000 LAN'.
#
# Example:
#	 ./setupWorkstationNetwork.sh
#
# When the first argument AX88179A is the Pi cluster connection name & the second argument eth1 is the
# internet connection.
#
# Example:
#	 ./setupWorkstationNetwork.sh AX88179A eth1
#
# Get the Ethernet devices with
# ifconfig -a


checkIfSSHCopyIdIsMissing () {
	! command -v ssh-copy-id &> /dev/null
}

brewInstallSSHCopyId () {
  brew install ssh-copy-id
}

installSSHCopyId () {
  if checkIfSSHCopyIdIsMissing; then
    brewInstallSSHCopyId
  fi
}

checkIfThereAreArguments () {
	[ "$#" -eq 1 ]
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

setNetworkInterfaceNamesAutomatically () {
	echo "Setting up internet interface names automatically"
	INTERNETCONNECTION=$(netstat -rn | grep default | head -n 1 | awk '{print $NF}')
	networksetup -setmanual 'USB 10/100/1000 LAN' 10.0.0.10 255.255.255.0
}

setInterfaceNamesAutomatically () {
	echo "Setting up interface names automatically"
	CLUSTERCONNECTION=$(networksetup -listallhardwareports | grep -A 1 'USB 10/100/1000 LAN' | tail -n 1 | awk '{print $NF}')
	setNetworkInterfaceNamesAutomatically
}

setInterfaceNames () {
	if checkIfThereAreArguments $@; then
		setCLUSTERCONNECTION $1
		setNetworkInterfaceNamesAutomatically
	elif checkIfThereAreTwoArguments $@; then
		setCLUSTERCONNECTION $1
		setINTERNETCONNECTION $2
	else
		setInterfaceNamesAutomatically
	fi
}

setupStaticIp () {
	echo "Setting up static IP"
	networksetup -setmanual 'USB 10/100/1000 LAN' 10.0.0.10 255.255.255.0
	wait
}

enablePackageForwarding () {
	echo "Enabling packet forwarding"
	sudo sysctl -w net.inet.ip.forwarding=1
	sudo sysctl -w net.inet6.ip6.forwarding=1
}

createANatRulesFileForPfctl () {
	echo "scrub on $INTERNETCONNECTION reassemble tcp no-df random-id" > nat-rules
	echo "nat on $INTERNETCONNECTION from 10.0.0.0/24 to any -> $INTERNETCONNECTION" >> nat-rules
}

enableNewNatRules () {
	sudo pfctl -e -f ./nat-rules
	wait
	rm ./nat-rules
}

setupNat () {
	echo "Setting up NAT"
	createANatRulesFileForPfctl
	enableNewNatRules
}

getInternetIntoThePis () {
	enablePackageForwarding
	setupNat
}

checkIfHostsFileIsMissingHostnames () {
	! grep -q "Pi Cluster" /private/etc/hosts
}

writeHostnamesIntoHostsFile () {
	echo "" | sudo tee -a /private/etc/hosts
	echo "# Pi Cluster" | sudo tee -a /private/etc/hosts
	for hostItr in {1..5}; do
		echo "10.0.0.$hostItr node0$hostItr" | sudo tee -a /private/etc/hosts
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
	grep "node0$1" ~/.ssh/known_hosts
}

checkIfOldNodeKeyIsInKnownHosts () {
	checkIfKnownHostsFileExists && checkIfNodeHostnameIsInKnownHosts $1
}

checkIfWeCanPingPi () {
	ping -c 1 -W 1 node0$1 | grep -q "1.*received"
}

removeOldNodeKeyFromKnownHosts () {
	ssh-keygen -R "node0$1"
}

copyPublicKeysToPIs () {
	if checkIfOldNodeKeyIsInKnownHosts $1; then
		removeOldNodeKeyFromKnownHosts $1
	fi

	ssh-copy-id -o ConnectTimeout=2 -o StrictHostKeyChecking=accept-new pi@node0$1
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
	sudo sysctl -a | grep "net.inet.ip.forwarding\|net.inet6.ip6.forwarding"

	echo
	echo "NAT Settings:"
	echo "**********************"
	netstat -rn | grep " $CLUSTERCONNECTION"
}

main () {
	installSSHCopyId
	setInterfaceNames $@
	setupStaticIp
	getInternetIntoThePis
	if checkIfHostsFileIsMissingHostnames; then
		writeHostnamesIntoHostsFile
	fi
	setupPasswordlessSSH
	printSettings
}

main $@
