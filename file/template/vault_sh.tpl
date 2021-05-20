cat <<-EOF > ~/script/vault/vault.sh
#!/bin/sh
set -e

# pki
cd ~/cfssl
vault secrets enable pki
vault secrets tune -max-lease-ttl=43800h pki
vault write -field csr pki/intermediate/generate/internal common_name="hashiporx Intermediate CA" ttl=43800h > ~/cfssl/intermediate.csr

cfssl sign -config ~/cfssl/ca-config.json -profile intermediate -ca ~/cfssl/ca.pem -ca-key ~/cfssl/ca-key.pem ~/cfssl/intermediate.csr | cfssljson -bare intermediate

cat intermediate.pem ca.pem > bundle.pem
vault write pki/intermediate/set-signed certificate=@bundle.pem

vault write pki/roles/${CERT_DOMAIN} \
        allowed_domains="${CERT_DOMAIN}" \
        allow_subdomains=true \
        max_ttl="43800h"

vault policy write pki_create ~/policy/pki_policy.hcl

# auth userpass
vault auth enable userpass
vault write auth/userpass/users/user password=password policies=pki_create
EOF

