#! /bin/bash


getNodeID () {
	NODEID=${HOSTNAME: -1}
}

createEth0InterfaceWithStaticIp () {
	sudo rm /etc/network/interfaces.d/eth0
	sudo touch /etc/network/interfaces.d/eth0
	sudo tee -a /etc/network/interfaces.d/eth0 << EOF
auto eth0
iface eth0 inet static
	address 10.0.0.$NODEID
	netmask 255.255.255.0
	gateway 10.0.0.10
	dns-nameserver 8.8.8.8
EOF
}

addStaticIP () {
	echo "Setting up static IP with /etc/network/inerfaces.d"
	createEth0InterfaceWithStaticIp
}

checkIfHostnamesAreMissing () {
	! grep -q "10.0.0.1.*node01" /etc/hosts
}

removePreviousHostnameIPMappings () {
	sed -i ':a;N;$!ba; s|\n127.0.1.1.*node0$hostItr||g' /etc/hosts
}

writeHostnamesIntoHostsFile () {
	echo "" | sudo tee -a /etc/hosts
	echo "Pi Cluster" | sudo tee -a /etc/hosts
	for hostItr in {1..5}; do
		echo "10.0.0.$hostItr node0$hostItr" | sudo tee -a /etc/hosts
	done
}

addHostnames () {
	if checkIfHostnamesAreMissing; then
		echo "Setting up Hostnames"
		removePreviousHostnameIPMappings
		writeHostnamesIntoHostsFile
	else
		echo "Hostnames already set up"
	fi
}

main () {
	getNodeID
	addStaticIP
	addHostnames
}

main

