##!/bin/sh
set -e 

~/script/consul.sh

sed -i '$aservice_registration "consul" {\n  address      = "127.0.0.1:8500"\n}' /etc/vault.d/vault.hcl

systemctl restart vault
sleep 3

~/script/vault/vault_unseal.sh
