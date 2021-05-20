cat <<-EOF > ~/script/consul-cert-var.sh
#!/bin/sh
set -e

export NIC_NAME=$(nmcli -t con |cut -d ":" -f 1)
export DC_NAME="dc1"
export DOMAIN_NAME="${CERT_DOMAIN}"
export IP_ADDRESS=$(ip -f inet -o addr show $NIC_NAME|cut -d\  -f 7 | cut -d/ -f 1)
export VAULT_SERVER=${VAULT_SERVER}
export VAULT_ADDR="https://${VAULT_SERVER}:8200"
EOF


