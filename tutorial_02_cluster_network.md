## Build a HPC-Cluster with Raspberry Pis

Now we will set up the network of the Pi nodes such that the nodes can access the internet.

### Setup Pi Cluster Network

First we give each cluster node a static IP. Mount bootfs on the SD card. On Ubuntu that usually works automatically by inserting the SD card into your laptop. Add an interface file into to the `interfaces.d`` folder `[...]/bootfs/cmdline.txt` and add `ip=10.0.0.<nodeID>` at the end of the line. That will change the IP of the node to a static IP such that we can access it from mac. **Make sure you choose for each node one of the** `<nodeID>` **IDs 1, 2, ... and 5.** Repeat the process for all Pi nodes and insert the SD cards into the cluster.

Next we set up the network and ssh for each Pi node. First open a Terminal and login to the node with `ssh pi@node0<nodeID>`\`. The password is as previously selected `raspberry`.

```bash
ssh pi@node0<nodeID>
```

On the Pi we first set up the network interface. Create a new file `/etc/network/interfaces.d/eth0` and add the node IP, the Netmask with Subnet length 24, the workstation IP as the default gateway and Googles server as the DNS nameserver.

```bash
sudo nano /etc/network/interfaces.d/eth0
```

eth0:

```
auto eth0
iface eth0 inet static
	address 10.0.0.<nodeID>
	netmask 255.255.255.0
	gateway 10.0.0.10
	dns-nameserver 8.8.8.8
```

Next also modify `/etc/hosts` as previously on your laptop such that each node of the cluster can see all other nodes. Add the mapping of hostnames to IPs to the end of the file. **Remove the line containing the loopback address** `127.0.1.1 node0[1-5]`

```bash
sudo nano /etc/hosts
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

After modifying all SD cards insert them into the Pi cluster and restart it by powering off and on the whole system. After a warm-up time ping all nodes with `ping node01`, `ping node02`, etc. to see if everything is working. The startup can take up to 3 Minutes.
