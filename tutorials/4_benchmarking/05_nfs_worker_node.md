## Prerequisites

Setting up NFS for simple file sharing.

### Set up the Worker Nodes:

SSH into each worker node:

```bash
ssh pi@node0[2...5]
```

Create a directory for mounting the shared NFS folder and set the ownership:

```bash
sudo mkdir /mnt/nfs
sudo chown -R pi:pi /mnt/nfs
```

Mount the shared directory from the master node:

```bash
sudo mount node01:/mnt/nfs /mnt/nfs
```

Create a test file to verify the mount:

```bash
touch /mnt/nfs/file_$HOSTNAME
```

Edit the /etc/rc.local file to ensure services are started at boot. Add the following lines before `exit 0`:

/etc/rc.local:

```bash
sudo /etc/init.d/nfs-common restart
sudo mount node01:/mnt/nfs /mnt/nfs
```

Repeat the steps for all worker nodes in your cluster. Once configured, the Raspberry Pi cluster will be able to share files via NFS. This allows you to access a shared directory on the master node from all the worker nodes.