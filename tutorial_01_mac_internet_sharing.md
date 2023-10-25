## Build a HPC-Cluster with Raspberry Pis

Now we will setup the mac workstation to be able to share internet with the cluster.

### Share the Internet Connection

First we enable IP forwarding. Open a shell and enable ip forwarding with `sysctl`.

```bash
sudo sysctl -w net.inet.ip.forwarding=1
sudo sysctl -w net.inet6.ip6.forwarding=1
```

Next we create a NAT to forward packages from your device that has the internet connection to the Pi cluster. For that purpose we first create a `nat-rules` **file** and write the NAT rules to the `nat-rules` **file**. Here `en0` is the name of the device with the internet connection. You can figure out the device name with the `ifconfig` command. The location of the `nat-rules` **file** is the current directory of your terminal. The content of the `nat-rules` **file** is the following one.

nat-rules:

```
scrub on en0 reassemble tcp no-df random-id
nat on en0 from 10.0.0.0/24 to any -> en0
```

Next we apply the new NAT rules. For that purpose we deactivate the packet filter device controller, flush all rules and enable our new rules. For that run the following commands in the terminal.

```bash
sudo pfctl -d
sudo pfctl -F all
sudo pfctl -e -f ./nat-rules
sudo pfctl -s all
```
