# etcd

## Setting Up an etcd Cluster

We want to set up an etcd cluster running on nodes { `node02`, `node03`}. Therefore, steps relevant for setting up one etcd server instance need to be performed on each node of the set { `node02`, `node03`}.

First, we create a config file that sets up our etcd cluster on nodes { `node02`, `node03`}. Therefore, create the file `/opt/etcd/etcd.conf.yml` with the following content. Make sure to replace `<node ip>` with the IP address of the node and `<node hostname>` with the name of the node, e.g. `node02`.

`etcd.conf.yml`:

```bash
# This is the configuration file for the etcd server.

# Human-readable name for this member.
name: '<node hostname>'

# Path to the data directory.
data-dir: /opt/etcd/tmp

# Path to the dedicated wal directory.
wal-dir:

# Number of committed transactions to trigger a snapshot to disk.
snapshot-count: 10000

# Time (in milliseconds) of a heartbeat interval.
heartbeat-interval: 100

# Time (in milliseconds) for an election to timeout.
election-timeout: 1000

# Raise alarms when backend size exceeds the given quota. 0 means use the
# default quota.
quota-backend-bytes: 0

# List of comma separated URLs to listen on for peer traffic.
listen-peer-urls: http://<node ip>:2380

# List of comma separated URLs to listen on for client traffic.
listen-client-urls: http://<node ip>:2379,http://127.0.0.1:2379

# Maximum number of snapshot files to retain (0 is unlimited).
max-snapshots: 5

# Maximum number of wal files to retain (0 is unlimited).
max-wals: 5

# Comma-separated white list of origins for CORS (cross-origin resource sharing).
cors:

# List of this member's peer URLs to advertise to the rest of the cluster.
# The URLs needed to be a comma-separated list.
initial-advertise-peer-urls: http://<node ip>:2380

# List of this member's client URLs to advertise to the public.
# The URLs needed to be a comma-separated list.
advertise-client-urls: http://<node ip>:2379

# Discovery URL used to bootstrap the cluster.
discovery:

# Valid values include 'exit', 'proxy'
discovery-fallback: 'proxy'

# HTTP proxy to use for traffic to discovery service.
discovery-proxy:

# DNS domain used to bootstrap initial cluster.
discovery-srv:

# Initial cluster configuration for bootstrapping.
initial-cluster: node02=http://10.0.0.2:2380,node03=http://10.0.0.3:2380

# Initial cluster token for the etcd cluster during bootstrap.
initial-cluster-token: 'etcd-cluster'

# Reject reconfiguration requests that would cause quorum loss.
strict-reconfig-check: false

# Accept etcd V2 client requests
enable-v2: true

# Enable runtime profiling data via HTTP server
enable-pprof: true

# Valid values include 'on', 'readonly', 'off'
proxy: 'off'

# Time (in milliseconds) an endpoint will be held in a failed state.
proxy-failure-wait: 5000

# Time (in milliseconds) of the endpoints refresh interval.
proxy-refresh-interval: 30000

# Time (in milliseconds) for a dial to timeout.
proxy-dial-timeout: 1000

# Time (in milliseconds) for a write to timeout.
proxy-write-timeout: 5000

# Time (in milliseconds) for a read to timeout.
proxy-read-timeout: 0

client-transport-security:
    # Path to the client server TLS cert file.
    cert-file:

    # Path to the client server TLS key file.
    key-file:

    # Enable client cert authentication.
    client-cert-auth: false

    # Path to the client server TLS trusted CA cert file.
    trusted-ca-file:

    # Client TLS using generated certificates
    auto-tls: false

peer-transport-security:
    # Path to the peer server TLS cert file.
    cert-file:

    # Path to the peer server TLS key file.
    key-file:

    # Enable peer client cert authentication.
    client-cert-auth: false

    # Path to the peer server TLS trusted CA cert file.
    trusted-ca-file:

    # Peer TLS using generated certificates.
    auto-tls: false

# Enable debug-level logging for etcd.
debug: false

logger: zap

# Specify 'stdout' or 'stderr' to skip journald logging even when running under systemd.
log-outputs: [stderr]

# Configures log level. Only supports 'debug', 'info', 'warn', 'error', 'panic', or 'fatal'.
log-level: 'error'

# Force to create a new one member cluster.
force-new-cluster: false

auto-compaction-mode: periodic
auto-compaction-retention: "1"
```

Start the etcd server with the following command.

```bash
etcd --config-file /opt/etcd/etcd.conf.yml
```

Assuming everything is configured correctly and the server will not crash, this command will not automatically terminate. Therefore, you will not be able to interact with the corresponding bash session anymore unless you terminate the command. Also note that the server in each session shuts down when you close the session. Feel free to run the command in background. For this tutorial, it is sufficient to run it in foreground.

Start a new bash session on Pi `node02` and add a key-value pair and query the data afterward.

```bash
etcdctl put helloWorld "Hello world!"
etcdctl get helloWorld
```

Start a new bash session on Pi `node03` and query the key-value pair added on `node02` before.

```bash
etcdctl get helloWorld
```

ssh into `node01` of the physical Pi cluster. An etcd client from this node now shall run requests against the etcd cluster running on {`node02`, `node03`}. Per default, `etcdctl` sends requests to an etcd server running on the local host. However, `--endpoints` allows specifying other endpoints. With the following command, the client will send requests to the etcd cluster's servers running on { `node02` , `node03`}.

Run the following command to retrieve the data of the previously added key-value pair.

```bash
etcdctl --endpoints=10.0.0.2:2379,10.0.0.3:2379 get helloWorld
```
