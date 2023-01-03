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

echo "##### Downloading alertmanager binary file ######"
curl -s https://api.github.com/repos/prometheus/alertmanager/releases/latest| grep browser_download_url|grep linux-amd64|cut -d '"' -f 4|wget -qi -

echo "##### Creating directory #####"
mkdir -p /etc/alertmanager
mkdir -p /var/alertmanager/data

echo "###### Extracting alertmanager files #####"
tar -xvf alertmanager*.tar.gz
cd  alertmanager*/
cp alertmanager /usr/local/bin
cp amtool /usr/local/bin
cp alertmanager.yml /etc/alertmanager/
cd ..
rm -rf alertmanager*

echo "##### Change owner of config files #####"
chown -R prometheus:prometheus /etc/alertmanager


echo "##### Creating alertmangaer service. #####"
tee /etc/systemd/system/alertmanager.service <<EOF
[Unit]
Description=Alert Manager
Wants=network-online.target
After=network-online.target

[Service]
Restart=always
User=prometheus
ExecStart=/usr/local/bin/alertmanager --web.listen-address="127.0.0.1:9093" --storage.path="/var/alertmanager/data/" --config.file="/etc/alertmanager/alertmanager.yml" --cluster.advertise-address=127.0.0.1:9093

ExecReload=/bin/kill -HUP $MAINPID
TimeoutStopSec=20s
SendSIGKILL=no

[Install]
WantedBy=default.target
EOF

echo "##### Reload systemd daemon and start the service #####"
sudo systemctl daemon-reload
sudo systemctl start alertmanager
sudo systemctl enable alertmanager

echo "******** DONE ********"