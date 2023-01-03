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

echo "****** Stop firewalld and remove it ******"
systemctl stop firewalld
systemctl mask firewalld
dnf remove -y firewalld

## Install iptables
echo "****** Installing iptables ******"
dnf install -y iptables-services
systemctl enable iptables --now