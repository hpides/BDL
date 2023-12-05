# etcd

## Installing etcd's Benchmark Tool

You will need to use etcd's Go-based benchmark tool in the task. For this, please install Go on `node01`. For this, please execute the remaining commands on `node01`.

```bash
wget -q --progress=bar:force --show-progress https://go.dev/dl/go1.21.4.linux-arm64.tar.gz
```

Extract the archive into `/usr/local`, creating a Go file tree in `/usr/local/go`. Installation details: <https://go.dev/doc/install>.

```bash
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.4.linux-arm64.tar.gz
```

```bash
echo export PATH=$PATH:/usr/local/go/bin  >> ~/.environment_variables &&
source ~/.environment_variables
```

Also, please download the benchmark tool, which is located in the `etcd` GitHub repository.

```bash
wget -q --progress=bar:force --show-progress https://github.com/etcd-io/etcd/archive/refs/heads/main.zip
```

Now, unzip the `main.zip`.

```bash
unzip main.zip
```

After this, the directory `etcd-main` should exist in your current working directory. Please move this and change the owner as follows.

```bash
sudo mv etcd-main /opt/etcd-main &&
rm main.zip &&
sudo chown pi:hadoop -R /opt/etcd-main
```

Navigate into the etcd-main directory.

```bash
cd /opt/etcd-main
```

Now, you can use etcd's benchmark tool with the following command.

```bash
go run ./tools/benchmark
```

Since you do not provide any parameter with the above command, the tool should print the `--help` output, which should look as follows.

```bash
benchmark is a low-level benchmark tool for etcd3.
It uses gRPC client directly and does not depend on
etcd client library.

Usage:
  benchmark [command]

Available Commands:
  completion      Generate the autocompletion script for the specified shell
  help            Help about any command
[further lines not shown in this snippet]
```
