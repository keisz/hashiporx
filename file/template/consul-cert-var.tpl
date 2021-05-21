cat <<-EOF > ~/script/consul-cert-var.sh
#!/bin/sh
set -e

export DOMAIN_NAME="${CERT_DOMAIN}"
export VAULT_SERVER=${VAULT_SERVER}
export VAULT_ADDR="https://${VAULT_SERVER}:8200"
EOF


