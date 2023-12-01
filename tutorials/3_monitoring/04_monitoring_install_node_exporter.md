## Monitoring Setup

Now we install the dependencies required by our monitoring setup. Our monitoring setup consists of node_exporter, Prometheus and Grafana. node_exporter is a set of software probes measuring the hardware utilization provided by Prometheus. Prometheus a monitoring toolkit (e.g. node_exporter) that scrapes and stores data from software probes as time series. Grafana is a dashboard that nicely plots the data provided by Prometheus. All instructions have to be executed on all nodes.

### Update and Upgrade Raspberry Pi Nodes

First we make sure that all nodes are up-to-date and have the same software versions.

```bash
sudo apt update
sudo apt --yes upgrade
```

### Node Exporter Installation

For node_exporter we create on all nodes an `/opt/node-exporter` folder and download the node_exporter that will scrap our metrics.

```bash
sudo mkdir -p /opt/node-exporter
cd /opt/node-exporter
sudo wget -O node-exporter.tar.gz https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-arm64.tar.gz
```

Next we install node-exporter by extracting the node_exporter.

```bash
sudo tar xzf node-exporter.tar.gz --strip-components=1
```

Now we define a service which will automatically start and run node_exporter.

```bash
sudo tee /etc/systemd/system/nodeexporter.service << EOF
[Unit]
Description=Prometheus Node Exporter
Documentation=https://prometheus.io/docs/guides/node-exporter/
After=network-online.target

[Service]
User=pi
Restart=on-failure

ExecStart=/opt/node-exporter/node_exporter

[Install]
WantedBy=multi-user.target
EOF
```

As a last step we enable the `nodeexporter` service, start it and check the status. You should see an output that says `active (running)`.

```bash
sudo systemctl enable nodeexporter
sudo systemctl restart nodeexporter
sudo systemctl status --no-pager nodeexporter

● nodeexporter.service - Prometheus Node Exporter
     Loaded: loaded (/etc/systemd/system/nodeexporter.service; enabled; preset: enabled)
     Active: active (running) since Wed 2023-10-25 16:12:54 BST; 32min ago
       Docs: https://prometheus.io/docs/guides/node-exporter/
   Main PID: 2401 (node_exporter)
      Tasks: 9 (limit: 8741)
        CPU: 18.202s
     CGroup: /system.slice/nodeexporter.service
             └─2401 /opt/node-exporter/node_exporter

Oct 25 16:12:54 node01 node_exporter[2401]: level=info ts=2023-10-25T15:12:54.859Z caller=node_exporter.go:112 collector=thermal_zone
Oct 25 16:12:54 node01 node_exporter[2401]: level=info ts=2023-10-25T15:12:54.860Z caller=node_exporter.go:112 collector=time
Oct 25 16:12:54 node01 node_exporter[2401]: level=info ts=2023-10-25T15:12:54.860Z caller=node_exporter.go:112 collector=timex
Oct 25 16:12:54 node01 node_exporter[2401]: level=info ts=2023-10-25T15:12:54.860Z caller=node_exporter.go:112 collector=udp_queues
Oct 25 16:12:54 node01 node_exporter[2401]: level=info ts=2023-10-25T15:12:54.860Z caller=node_exporter.go:112 collector=uname
Oct 25 16:12:54 node01 node_exporter[2401]: level=info ts=2023-10-25T15:12:54.860Z caller=node_exporter.go:112 collector=vmstat
Oct 25 16:12:54 node01 node_exporter[2401]: level=info ts=2023-10-25T15:12:54.860Z caller=node_exporter.go:112 collector=xfs
Oct 25 16:12:54 node01 node_exporter[2401]: level=info ts=2023-10-25T15:12:54.861Z caller=node_exporter.go:112 collector=zfs
Oct 25 16:12:54 node01 node_exporter[2401]: level=info ts=2023-10-25T15:12:54.861Z caller=node_exporter.go:191 msg="Listening on" address=:9100
Oct 25 16:12:54 node01 node_exporter[2401]: level=info ts=2023-10-25T15:12:54.861Z caller=tls_config.go:170 msg="TLS is disabled and it cannot be enabled on the fly." http2=false
```

Now continue now with the Prometheus installation.
