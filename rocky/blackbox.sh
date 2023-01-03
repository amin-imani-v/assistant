#!/bin/bash

################################################
#                                              #
#                                              #
#     This script written by [AMIN IMANI]      #
#                    2022                      #
#                                              #
#                                              #
################################################

#ENV

## Add specific user and group for running prometheus 
echo "##### Adding a user and group for running prometheus #####"
groupadd --system prometheus
useradd -s /sbin/nologin --system -g prometheus prometheus

echo "##### Downloading blackbox_exporter binary file ######"
curl -s https://api.github.com/repos/prometheus/blackbox_exporter/releases/latest| grep browser_download_url|grep linux-amd64|cut -d '"' -f 4|wget -qi -

echo "##### Creating directory #####"
mkdir -p /etc/blackbox_exporter

echo "###### Extracting blackbox_exporter files #####"
tar -xvf blackbox_exporter*.tar.gz
cd  blackbox_exporter*/
cp blackbox_exporter /usr/local/bin
cp blackbox.yml /etc/blackbox_exporter/
cd ..
rm -rf blackbox_exporter*

echo "##### Change owner of config files #####"
chown -R prometheus:prometheus /etc/blackbox_exporter

echo "##### Creating blackbox_exporter service. #####"
tee /etc/systemd/system/blackbox_exporter.service <<EOF
[Unit]
Description=Black box for prometheus
Wants=network-online.target
After=network-online.target

[Service]
Restart=always
User=prometheus
ExecStart=/usr/local/bin/blackbox_exporter --web.listen-address="127.0.0.1:9115" --config.file="/etc/blackbox_exporter/blackbox.yml"

ExecReload=/bin/kill -HUP $MAINPID
TimeoutStopSec=20s
SendSIGKILL=no

[Install]
WantedBy=default.target
EOF

echo "##### Reload systemd daemon and start the service #####"
sudo systemctl daemon-reload
sudo systemctl start blackbox_exporter
sudo systemctl enable blackbox_exporter

echo "******** DONE ********"