#! /bin/bash

# Create configuration and data directories
mkdir /var/lib/prometheus
for i in rules rules.d files_sd; do mkdir -p /etc/prometheus/${i}; done

# Download and Install Prometheus onDebian
apt-get update
apt-get -y install wget curl
mkdir -p /tmp/prometheus && cd /tmp/prometheus
curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest|grep browser_download_url|grep linux-amd64|cut -d '"' -f 4|wget -qi -

# Extract the file.
tar xvf prometheus*.tar.gz
cd prometheus*/

# Move the prometheus binary files to /usr/local/bin/
mv prometheus promtool /usr/local/bin/

# Move prometheus configuration template to /etc directory.
mv prometheus.yml  /etc/prometheus/prometheus.yml

#  move consoles and console_libraries to /etc/prometheus directory
mv consoles/ console_libraries/ /etc/prometheus/
cd ~/
rm -rf /tmp/prometheus

# Create a Prometheus systemd Service unit file
tee /etc/systemd/system/prometheus.service<<EOF
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.external-url=

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Change directory permissions.
for i in rules rules.d files_sd; do chown -R prometheus:prometheus /etc/prometheus/${i}; done
for i in rules rules.d files_sd; do chmod -R 775 /etc/prometheus/${i}; done
chown -R prometheus:prometheus /var/lib/prometheus/

# Reload systemd daemon and start the service.
systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus
