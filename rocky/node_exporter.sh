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

echo "##### Downloading node_exporter binary file ######"
curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest| grep browser_download_url|grep linux-amd64|cut -d '"' -f 4|wget -qi -

echo "###### Extracting node_exporter files #####"
tar -xvf node_exporter*.tar.gz
cd  node_exporter*/
cp node_exporter /usr/local/bin
cd ../
rm -rf node_exporter*

echo "##### Creating node_exporter service. #####"
tee /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/node_exporter \
          --web.listen-address=127.0.0.1:9100

[Install]
WantedBy=default.target
EOF

echo "##### Reload systemd daemon and start the service #####"
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

echo "******** DONE ********"