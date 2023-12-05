# etcd

## Prerequisites

You have already done the cluster setup. Unless otherwise noted, all commands must be run on all nodes. If, for a specific command, you are curious about the purpose of a used command line option, feel free to `man <command>` for further details.

## Installing etcd

ssh into the node and run the following steps and their commands.

Download the archive containing the binaries.

```bash
wget -q --progress=bar:force --show-progress https://github.com/etcd-io/etcd/releases/download/v3.5.10/etcd-v3.5.10-linux-arm64.tar.gz
```

Extract the archive's files.

```bash
tar -xzf etcd-v3.5.10-linux-arm64.tar.gz --one-top-level --strip-components=1
```

Briefly view the extracted files. These should contain the executable binary files `etcd`, `etcdctl`, and `etcdutl`.

```bash
ls -al etcd-v3.5.10-linux-arm64
```

Move the files to the `/opt` folder, create a data directory folder, and change the access rights.

```bash
sudo mv etcd-v3.5.10-linux-arm64 /opt/etcd
sudo mkdir /opt/etcd/tmp
sudo chown pi:hadoop -R /opt/etcd
```

After extracting the files, the archive is no longer needed. Remove the archive.

```bash
rm etcd-v3.5.10-linux-arm64.tar.gz
```

Add the directory containing the binaries to `PATH`.
This allows conveniently calling the binary without specifying the path to the binaries. Note that the updated `PATH` is only valid during your current bash session.
Add the above line to the end of your `~/.environment_variables` file to use the updated' PATH' in every session.

```bash
echo export PATH="$PATH:/opt/etcd" >> ~/.environment_variables
source ~/.environment_variables
```

Now, you can call the three binaries mentioned above from any directory. Please verify that all binaries are executable by printing the binaries' versions.

```bash
etcd --version
etcdctl version
etcdutl version
```

## Documentation

If you have further questions or are curious about more etcd details, please visit <https://etcd.io/docs/v3.5/>.
For configuring etcd servers, you can find further details at https://etcd.io/docs/v3.5/op-guide/configuration/.