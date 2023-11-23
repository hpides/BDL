#! /bin/bash


# Usage: Has to be run on a cluster node!


updatePackageManager () {
	sudo apt update
	sudo apt --yes upgrade
}

checkIfIsMasterNode () {
	[ "$HOSTNAME" = "node01" ]
}

downloadNodeExplorer () {
	sudo rm -r /opt/node-exporter
	sudo mkdir -p /opt/node-exporter
	cd /opt/node-exporter
	sudo wget -q --progress=bar:force --show-progress -O node-exporter.tar.gz https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-arm64.tar.gz
}

extractNodeExplorer () {
	sudo tar xzf node-exporter.tar.gz --strip-components=1
	sudo rm node-exporter.tar.gz
}

configureNodeExplorer () {
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
}

enableNodeExplorer () {
	sudo systemctl enable nodeexporter
}

startNodeExplorer () {
	sudo systemctl restart nodeexporter
	sudo systemctl status --no-pager nodeexporter
}

installNodeExplorer () {
	downloadNodeExplorer
	extractNodeExplorer
	configureNodeExplorer
	enableNodeExplorer
	startNodeExplorer
}

downloadPrometheus () {
	cd ~
	wget -q --progress=bar:force --show-progress https://github.com/prometheus/prometheus/releases/download/v2.22.0/prometheus-2.22.0.linux-armv7.tar.gz
}

extractPrometheus () {
	tar xzf prometheus-2.22.0.linux-armv7.tar.gz
	rm -r prometheus
	mv prometheus-2.22.0.linux-armv7/ prometheus
	rm prometheus-2.22.0.linux-armv7.tar.gz
}

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
	sudo tee /home/pi/prometheus/prometheus.yml << EOF
# my global config
global:
	scrape_interval:		 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
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
}

enablePrometheus () {
	sudo systemctl enable prometheus
}

startPrometheus () {
	sudo systemctl restart prometheus
	sudo systemctl status --no-pager prometheus
}

installPrometheus () {
	downloadPrometheus
	extractPrometheus
	configurePrometheus
	enablePrometheus
	startPrometheus
}

checkIfGrafanaIsNotInSourceList () {
	[ ! -f /etc/apt/sources.list.d/grafana.list ]
}

deleteGrafana () {
	sudo apt --yes purge grafana
	sudo rm -r /etc/grafana
	sudo rm -r /var/lib/grafana
}

downloadGrafana () {
	wget -q --progress=bar:force --show-progress -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
	if checkIfGrafanaIsNotInSourceList; then
		echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
	fi
	sudo apt update
	sudo apt --yes install grafana
}

enableGrafana () {
	sudo systemctl enable grafana-server
}

startGrafana () {
	sudo systemctl restart grafana-server
	sudo systemctl status --no-pager grafana-server
}

installGrafana () {
	echo $HOSTNAME
	deleteGrafana
	downloadGrafana
	enableGrafana
	startGrafana
}

main () {
	echo "***********************************"
	echo "* Setting up $HOSTNAME"
	echo "***********************************"
	updatePackageManager
	installNodeExplorer
	if checkIfIsMasterNode; then
		installPrometheus
		installGrafana
	fi
}

main

