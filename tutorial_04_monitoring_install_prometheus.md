## Monitoring Setup

Next we install Prometheus.

### Prometheus Installation

First we download and extract the Prometheus package. These instructions should be executed only on the headnode.

```bash
cd ~
wget https://github.com/prometheus/prometheus/releases/download/v2.22.0/prometheus-2.22.0.linux-armv7.tar.gz
tar xzf prometheus-2.22.0.linux-armv7.tar.gz
mv prometheus-2.22.0.linux-armv7/ prometheus
```

Next we create a

```bash
configurePrometheus () {
	sudo tee /etc/systemd/system/prometheus.service << EOF
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network-online.target

[Service]
User=pi
Restart=on-failure

ExecStart=/home/pi/prometheus/prometheus \
  --config.file=/home/pi/prometheus/prometheus.yml \
  --storage.tsdb.path=/home/pi/prometheus/data

[Install]
WantedBy=multi-user.target
EOF
}
```

Next we configure Prometheus to access the node_exporters on all nodes.

```bash
sudo tee /home/pi/prometheus/prometheus.yml << EOF
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label 'job=' to any timeseries scraped from this config.
  - job_name: 'node01'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['node01:9100']
  - job_name: 'node02'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['node02:9100']
  - job_name: 'node03'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['node03:9100']
  - job_name: 'node04'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['node04:9100']
  - job_name: 'node05'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['node05:9100']
EOF
```

Finally we enable the Prometheus service, start it and check the service status. You should see an output that says `active (running)`.

```bash
sudo systemctl enable prometheus
sudo systemctl restart prometheus
sudo systemctl status --no-pager prometheus

● prometheus.service - Prometheus Server
     Loaded: loaded (/etc/systemd/system/prometheus.service; enabled; preset: enabled)
     Active: active (running) since Wed 2023-10-25 16:13:02 BST; 31min ago
       Docs: https://prometheus.io/docs/introduction/overview/
   Main PID: 2438 (prometheus)
      Tasks: 9 (limit: 8741)
        CPU: 5.253s
     CGroup: /system.slice/prometheus.service
             └─2438 /home/pi/prometheus/prometheus --config.file=/home/pi/prometheus/prometheus.yml --storage.tsdb.path=/home/pi/prometheus/data

Oct 25 16:13:02 node01 prometheus[2438]: level=info ts=2023-10-25T15:13:02.624Z caller=head.go:642 component=tsdb msg="Replaying on-disk memory mappable chunks if any"
Oct 25 16:13:02 node01 prometheus[2438]: level=info ts=2023-10-25T15:13:02.624Z caller=head.go:656 component=tsdb msg="On-disk memory mappable chunks replay completed" duration=13.407µs
Oct 25 16:13:02 node01 prometheus[2438]: level=info ts=2023-10-25T15:13:02.624Z caller=head.go:662 component=tsdb msg="Replaying WAL, this may take a while"
Oct 25 16:13:02 node01 prometheus[2438]: level=info ts=2023-10-25T15:13:02.624Z caller=head.go:714 component=tsdb msg="WAL segment loaded" segment=0 maxSegment=0
Oct 25 16:13:02 node01 prometheus[2438]: level=info ts=2023-10-25T15:13:02.625Z caller=head.go:719 component=tsdb msg="WAL replay completed" checkpoint_replay_duration=99.942µs wal_re…ration=782.468µs
Oct 25 16:13:02 node01 prometheus[2438]: level=info ts=2023-10-25T15:13:02.632Z caller=main.go:732 fs_type=EXT4_SUPER_MAGIC
Oct 25 16:13:02 node01 prometheus[2438]: level=info ts=2023-10-25T15:13:02.632Z caller=main.go:735 msg="TSDB started"
Oct 25 16:13:02 node01 prometheus[2438]: level=info ts=2023-10-25T15:13:02.633Z caller=main.go:861 msg="Loading configuration file" filename=/home/pi/prometheus/prometheus.yml
Oct 25 16:13:02 node01 prometheus[2438]: level=info ts=2023-10-25T15:13:02.637Z caller=main.go:892 msg="Completed loading of configuration file" filename=/home/pi/prometheus/prometheus.yml totalDurat…
Oct 25 16:13:02 node01 prometheus[2438]: level=info ts=2023-10-25T15:13:02.637Z caller=main.go:684 msg="Server is ready to receive web requests."
Hint: Some lines were ellipsized, use -l to show in full.
```

Now you should be able to access Prometheus via `http://node01:9090`.

Next continue with the Grafana tutorial.
