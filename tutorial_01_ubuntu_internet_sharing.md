## Build a HPC-Cluster with Raspberry Pis

Now we will set up the Ubuntu workstation to be able to share internet with the cluster.

### Share the Internet Connection

First route packets via the Pi cluster connection.

```bash
sudo ip route add 10.0.0.0/24 dev eth1 proto kernel scope link src 10.0.0.10
```

Enable packet forwarding on your laptop.

```bash
sudo sysctl net.ipv4.ip_forward=1
sudo sysctl net.ipv6.conf.default.forwarding=1
sudo sysctl net.ipv6.conf.all.forwarding=1
```

Next enable to NAT packets to the internet connection such that the Pi cluster has a working internet connection.

```bash
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
```

When everything you should have the following additional route. You can check them with `ip route show`.

```bash
ip route show

10.0.0.0/24 dev eth1 proto kernel scope link src 10.0.0.10
```
