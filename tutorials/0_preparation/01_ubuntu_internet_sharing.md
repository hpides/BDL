## Build a HPC-Cluster with Raspberry Pis

Now we will set up the Ubuntu workstation to be able to share internet with the cluster.

### Share the Internet Connection

First we enable packet forwarding on your laptop.

```bash
sudo sysctl net.ipv4.ip_forward=1
sudo sysctl net.ipv6.conf.default.forwarding=1
sudo sysctl net.ipv6.conf.all.forwarding=1
```

Next enable to NAT packets to the internet connection such that the Pi cluster has a working internet connection. Check the available adapters on your laptop with the following command. 

```
ifconfig -a
```
The output should contain at least two adapters: your workstation's internet device (eth0) and the connection to the cluster (eth1).
```
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

Make sure to replace eth0 and eth1 with the suitable aliases provided by your ```ifconfig -a``` output.

```bash
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
```

When everything you should have the following additional route. You can check them with `ip route show`.

```bash
ip route show

[...]
10.0.0.0/24 dev eth1 proto kernel scope link src 10.0.0.10
[...]
```
