## Build a HPC-Cluster with Raspberry Pis

Now we will install an OS on the Pi nodes, setup static IP addresses and ssh connections for further tutorials.

### Setup Pi Cluster Network

First we give each cluster node a static IP. Mount rootfs on the SD card. On Ubuntu that usually works automatically by inserting the SD card into your laptop. Add an interface file into to the interfaces folder  `touch [...]/rootfs/etc/network/interfaces.d/eth0` and add the following lines into that file but **make sure you choose for each node one of the** `<nodeID>` **IDs 1, 2, ... and 5.**

eth0:

```shellscript
auto eth0
iface eth0 inet static
	address 10.0.0.<nodeID>
	netmask 255.255.255.0
	gateway 10.0.0.10
	dns-nameserver 8.8.8.8
```

Next also modify `[...]/rootfs/etc/hosts`  as previously on your laptop such that each node of the cluster can see all other nodes. Add the mapping of hostnames to IPs to the end of the file.

```
sudo nano [...]/rootfs/etc/hosts
```

hosts:

```
[...]

10.0.0.1	node01
10.0.0.2	node02
10.0.0.3	node03
10.0.0.4	node04
10.0.0.5	node05
```

After modifying all SD cards insert them into the Pi cluster and restart it by powering off and on the whole system. After a warm-up time ping all nodes with `ping node01` ,  `ping node02` , etc. to see if everything is working. The startup can take up to 3 Minutes.

### Setup Workstation Network with

First insert the Ethernet USB adapter into your laptop and then figure out which ethernet device is connected to the internet and which ethernet device is connected to the Pi cluster. `ifconfig -a` helps you to figure out the device name. In the following example is `eth0` the device connected to the internet and `eth1` the device connected to the Pi cluster.

```
ifconfig -a

eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 168.192.13.133  netmask 255.255.252.0  broadcast 172.17.19.255
        inet6 2001::14eb:3fab:65ac  prefixlen 64  scopeid 0x0<global>
        inet6 2001::c82b:acaf:128f  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::f46f:4eb4:307f  prefixlen 64  scopeid 0x20<link>
        ether 74:78:27:a2:0c:78  txqueuelen 1000  (Ethernet)
        RX packets 256730  bytes 250147903 (250.1 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 79750  bytes 20964548 (20.9 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 00:0e:cc:66:fc:33  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (472.5 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (138.3 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

Next setup an IP for the Pi cluster connection on your working station or laptop.

```
sudo ip addr add 10.0.0.10 dev eth1
```

Route packets via the Pi cluster connection.

```
sudo ip route add 10.0.0.0/24 dev eth1 proto kernel scope link src 10.0.0.10
```

Enable packet forwarding on your laptop.

```
sudo sysctl net.ipv4.ip_forward=1
sudo sysctl net.ipv6.conf.default.forwarding=1
sudo sysctl net.ipv6.conf.all.forwarding=1
```

Next enable to NAT packets to the internet connection such that the Pi cluster has a working internet connection.

```
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
```

When everything you should have the following additional route. You can check them with `ip route show` .

```shellscript
ip route show

10.0.0.0/24 dev eth1 proto kernel scope link src 10.0.0.10
```

Finally add all the node names to your laptop by modifying your `/etc/hosts`  file. Add the mapping of hostnames to IPs to the end of the file.

hosts:

```
[...]

# Pi Cluster
10.0.0.1	node01
10.0.0.2	node02
10.0.0.3	node03
10.0.0.4	node04
10.0.0.5	node05
```

Next we setup passwordless ssh. That allows us to ssh into the Pis without entering the password. First check if you already have an key pair with `ls -A ~/.ssh/id_*`. The command should print at least one key pair like in the following example.

```
ls -A ~/.ssh/id_*

/home/username/.ssh/id_ed25519  /home/username/.ssh/id_ed25519.pub
```

If you have no key pair create one with `ssh-keygen -q -t ed25519 -N '' <<< $'\ny' >/dev/null` .
Finally copy for each Pi your public key to the Pi with `ssh-copy-id -o StrictHostKeyChecking=accept-new pi@node0$keyItr`. We set the password before to `raspberry`.

```shellscript
ssh-copy-id -o StrictHostKeyChecking=accept-new pi@node01
ssh-copy-id -o StrictHostKeyChecking=accept-new pi@node02
ssh-copy-id -o StrictHostKeyChecking=accept-new pi@node03
ssh-copy-id -o StrictHostKeyChecking=accept-new pi@node04
ssh-copy-id -o StrictHostKeyChecking=accept-new pi@node05
```

### Setup the Pi Nodes

This section has to be repeat for each node. Connect to the node with `ssh pi@node01`. Once you successfully SSH into the PI, upgrade the package manager with:

```
sudo apt update
sudo apt upgrade
```

Next setup passwordless ssh. First create a key pair and then copy the public key to all nodes.

```shellscript
ssh-keygen -q -t ed25519 -N '' <<< \\\$'\ny' >/dev/null 2>&1

ssh-copy-id -o StrictHostKeyChecking=accept-new pi@node01
ssh-copy-id -o StrictHostKeyChecking=accept-new pi@node02
ssh-copy-id -o StrictHostKeyChecking=accept-new pi@node03
ssh-copy-id -o StrictHostKeyChecking=accept-new pi@node04
ssh-copy-id -o StrictHostKeyChecking=accept-new pi@node05
```

Finally we create a `~/.environment_variables` file that will be always executed by the `~/.bashrc` file when logging into the Pis. Therefore we add a line to the start of the `~/.bashrc` file.

.bashrc:

```shellscript
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

. ~/.environment_variables

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

[...]
```