## Prerequisites

Setting up NFS for simple file sharing.

### Install the NFS server on the head node

SSH into the head node:

```bash
ssh pi@node01
```

Install the NFS server package, create a shared directory, and set the ownership:

```bash
sudo apt-get update
sudo apt-get install nfs-kernel-server -y
sudo mkdir /mnt/nfs
sudo chown -R pi:pi /mnt/nfs
```

Edit the `/etc/exports` file to specify which worker nodes can access the shared directory. Add the following lines:

/etc/exports:

```bash
/mnt/nfs node02(rw,sync,no_subtree_check)
/mnt/nfs node03(rw,sync,no_subtree_check)
/mnt/nfs node04(rw,sync,no_subtree_check)
/mnt/nfs node05(rw,sync,no_subtree_check)
```

Restart the necessary services to apply the configuration changes:

```bash
sudo /etc/init.d/rpcbind restart
sudo /etc/init.d/nfs-kernel-server restart
sudo exportfs -r
```

Edit the `/etc/rc.local` file to ensure services are started at boot. Add the following lines before `exit 0`:

/etc/rc.local:

```bash
sudo /etc/init.d/rpcbind restart
sudo /etc/init.d/nfs-kernel-server restart
```
