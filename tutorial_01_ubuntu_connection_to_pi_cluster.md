## Build a HPC-Cluster with Raspberry Pis

Now we will setup the Ubuntu workstation to be able to ssh into the cluster nodes.

### Setup Workstation Network

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

Now you are able to connect to the pi nodes with e.g. `ssh pi@node01` when they are running.
