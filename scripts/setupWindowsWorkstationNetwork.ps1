# Usage: Either write the Ethernet interfaces here or provide them as arguments.
# When the internet he frst argument is the Pi cluster connection & the second argument is the
# internet connection.
#
# Example:
#	 ./setupWorkstationNetwork.sh 6 69


function checkIfNotAdmin () {
	$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	$out = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
	$(-not $out)
}

function runScriptOnlyAsAdmin () {
	start-process powershell -verb runAs "$PSCommandPath"
	exit
}

function enablePackageForwarding () {
	echo "Enabling packet forwarding"
	set-netipinterface -forwarding enabled
}

function createNetSharingManager () {
	regsvr32 hnetcfg.dll
	$(New-Object -ComObject HNetCfg.HNetShare)
}

function getInterfaceNameWithIndex ($ifindex) {
	$(Get-NetAdapter -interfaceindex $ifindex).name
}

function getConnectionWithName ($m, $ifname) {
	$($m.EnumEveryConnection |? { $m.NetConnectionProps.Invoke($_).Name -eq $ifname })
}

function getInterfaceConfiguration ($m, $ifname) {
	$con = getConnectionWithName -m $m -ifname $ifname

	$($m.INetSharingConfigurationForINetConnection.Invoke($con))
}

function setInterfaceAsInternetProvider ($config) {
	$config.EnableSharing(0)
	$global:InternetProviderInterfaceConfig = $config
}

function configureInternetProviderSide ($m) {
	$ifname = getInterfaceNameWithIndex -ifindex $INTERNETCONNECTION

	$config = getInterfaceConfiguration -m $m -ifname $ifname

	setInterfaceAsInternetProvider -config $config
}

function setInterfaceAsInternetConsumer ($config) {
	$config.EnableSharing(1)
	$global:InternetConsumerInterfaceConfig = $config
}

function configureInternetConsumerSide ($m) {
	$ifname = getInterfaceNameWithIndex -ifindex $CLUSTERCONNECTION

	$config = getInterfaceConfiguration -m $m -ifname $ifname

	setInterfaceAsInternetConsumer -config $config
}

function shareInternet () {
	$m = createNetSharingManager

	configureInternetProviderSide -m $m

	configureInternetConsumerSide -m $m
}

function getInternetIntoThePis () {
	enablePackageForwarding
	shareInternet
}

function checkIfThereAreTwoArguments ($argv) {
	$($argv.Count -eq 2)
}

function setCLUSTERCONNECTION ($interfaceName) {
	$global:CLUSTERCONNECTION=$interfaceName
}

function setINTERNETCONNECTION ($interfaceName) {
	$global:INTERNETCONNECTION=$interfaceName
}

function getIdOfUsbEthernetDongle () {
	$out = netstat -rn | select-string -pattern "Realtek USB GbE Family Controller"
	$null = $out -match " ?(.*)\.\.\.[0-9]"
	$($matches[1])
}

function getIdOfInternetInterface () {
	$out = get-netroute -destinationprefix '0.0.0.0/0', '::/0' | Select-Object -First 1
	$out.ifIndex
}

function setInterfaceNamesAutomatically () {
	echo "Setting up interface names automatically"
	$global:CLUSTERCONNECTION=getIdOfUsbEthernetDongle
	$global:INTERNETCONNECTION=getIdOfInternetInterface
}

function setInterfaceNames ($argv) {
	if (checkIfThereAreTwoArguments -argv $argv) {
		setCLUSTERCONNECTION -interfaceName $argv[0]
		setINTERNETCONNECTION -interfaceName $argv[1]
	} else {
		setInterfaceNamesAutomatically
	}
}

function setupStaticIp () {
	echo "Setting up static IP"
	$null = remove-netipaddress -confirm:$false -interfaceindex $CLUSTERCONNECTION
	$null = new-netipaddress -interfaceindex $CLUSTERCONNECTION -addressfamily IPv4 -ipaddress 10.0.0.10 -prefixlength 24
}

function checkIfHostsFileIsMissingHostnames () {
	$out = $null
	$out = select-string -path "$env:SystemRoot\System32\drivers\etc\hosts" -pattern "# Pi Cluster"
	$($out -eq $null)
}

function writeHostnamesIntoHostsFile () {
	$hostnames = "`n`n# Pi Cluster"
	for ($hostItr = 1; $hostItr -le 5; $hostItr++) {
		$hostnames = "$hostnames`n10.0.0.$hostItr node0$hostItr"
	}
	Add-Content -Path "$env:SystemRoot\System32\drivers\etc\hosts" -Value $hostnames
}

function checkIfWeHaveNoSSHKey () {
	$out = $null
	$out = get-childitem ~/.ssh/id_*
	$($out -eq $null)
}

function createNewSSHKey () {
	$null = (echo "`ny" | ssh-keygen -q -t ed25519 -N "''")
}

function checkIfKnownHostsFileExists () {
	$out = test-path ~/.ssh/known_hosts
	$($out -eq "true")
}

function checkIfNodeHostnameIsInKnownHosts ($nodeID) {
	$out = $null
	$out = select-string -path ~/.ssh/known_hosts -pattern "node0$nodeID"
	$($out -ne $null)
}

function checkIfOldNodeKeyIsInKnownHosts ($nodeID) {
	$(checkIfKnownHostsFileExists -and checkIfNodeHostnameIsInKnownHosts -nodeID $nodeID)
}

function removeOldNodeKeyFromKnownHosts ($nodeID) {
	$null = ssh-keygen -R "node0$nodeID"
}

function sshCopyID ($nodeID) {
	$table = get-childitem ~/.ssh/*.pub | where {! $_.PSIsContainer}
	foreach ($row in $table) {
		cat ~/.ssh/$($row.Name) | ssh -o ConnectTimeout=2 pi@node0$nodeID "cat >> ~/.ssh/authorized_keys"
	}
}

function copyPublicKeysToPIs ($nodeID) {
	if (checkIfOldNodeKeyIsInKnownHosts -nodeID $nodeID) {
		removeOldNodeKeyFromKnownHosts -nodeID $nodeID
	}

	sshCopyID -nodeID $nodeID
}

function setupPasswordlessSSH () {
	echo "Setting up passwordless SSH"
	if (checkIfWeHaveNoSSHKey) {
		echo "Creating new SSH key"
		createNewSSHKey
	}

	for ($hostItr = 1; $hostItr -le 5; $hostItr++) {
		copyPublicKeysToPIs -nodeID $hostItr
	}
}

function checkIfInternetInterfaceSharesInternet () {
	$(Write-Output $InternetProviderInterfaceConfig.SharingEnabled)
}

function checkIfClusterInterfaceReceivesInternet () {
	$(Write-Output $InternetConsumerInterfaceConfig.SharingEnabled)
}

function printSettings () {
	echo "`nPi Cluster Interface:"
	echo "*********************"
	echo $CLUSTERCONNECTION

	echo "`nInternet Interface:"
	echo "*********************"
	echo $INTERNETCONNECTION

	echo "`nPacket Forwarding Settings:"
	echo "*****************************"
	get-netipinterface -interfaceindex 6,69 | select ifindex,interfacealias,addressfamily,connectionstate,Forwarding | format-table

	echo "`nInternet Sharing Settings:"
	echo "**********************"
	if (checkIfInternetInterfaceSharesInternet) {
		echo "Internet interface shares internet"
	} else {
		echo "Internet interface does NOT share internet"
	}
	if (checkIfClusterInterfaceReceivesInternet) {
		echo "Pi Cluster interface receives internet"
	} else {
		echo "Pi Cluster interface does NOT receive internet"
	}
}

function main ($argv) {
	if (checkIfNotAdmin) {
		runScriptOnlyAsAdmin
	}
	setInterfaceNames -argv $argv
	getInternetIntoThePis
	setupStaticIp
	if (checkIfHostsFileIsMissingHostnames) {
		writeHostnamesIntoHostsFile
	}
	setupPasswordlessSSH
	printSettings
}

main -argv $args
