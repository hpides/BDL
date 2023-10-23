## Build a HPC-Cluster with Raspberry Pis

Now we will setup the mac workstation to be able to share internet with the cluster.

### Share the Internet Connection

First we enable IP forwarding. Open a shell and enable ip forwarding with `sysctl`.

```
sudo sysctl -w net.inet.ip.forwarding=1
sudo sysctl -w net.inet6.ip6.forwarding=1
```

Next we create a NAT to forward packages from you device that has the internet connection to the Pi cluster. For that purpose we first define a `nat-rules` file and add the NAT rules. Here `en0` is the name of the device with the internet connection. You can figure out the device name with the `ifconfig` command.

nat-rules:

```
scrub on en0 reassemble tcp no-df random-id
nat on en0 from 10.0.0.0/24 to any -> en0
```

Next we deactivate the packet filter device controller, flush all rules and enable our new rules. For that run the following commands in the terminal.

```
sudo pfctl -d
sudo pfctl -F all
sudo pfctl -e -f ./nat-rules
sudo pfctl -s all
```
