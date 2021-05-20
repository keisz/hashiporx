#!/bin/sh
set -e

~/script/consul-cert.sh
sleep 3

systemctl start consul
systemctl enable consul

systemctl start dnsmasq
systemctl enable dnsmasq

export NIC_NAME=$(nmcli -t con |cut -d ":" -f 1)
nmcli con modify $NIC_NAME ipv4.dns 127.0.0.1
nmcli con reload
nmcli con down $NIC_NAME && nmcli con up $NIC_NAME

