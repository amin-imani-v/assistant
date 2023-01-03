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

## Install nginx
echo "Installing nginx"
touch /etc/yum.repos.d/nginx.repo
tee /etc/yum.repos.d/nginx.repo <<EOF
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/8/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/8/x86_64/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
yum install yum-utils -y
yum-config-manager --enable nginx-mainline
yum update -y
yum install nginx -y
rm -rf /etc/nginx/conf.d/default.conf
systemctl enable nginx --now

setsebool httpd_can_network_connect 1 -P
