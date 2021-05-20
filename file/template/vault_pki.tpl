cat <<-EOF > ~/script/vault/vault-pki.sh
#!/bin/sh
set -e

source ~/script/vault/vault_login.sh
mkdir ~/ca && cd ~/ca

## Root CAの作成 
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki
vault write -field=certificate pki/root/generate/internal \
        common_name="VaultCA" \
        ttl=87600h > CA_cert.crt
vault write pki/config/urls \
        issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" \
        crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"

## 中間CAの作成
vault secrets enable -path=pki_int pki
vault secrets tune -max-lease-ttl=73800h pki_int
vault write -format=json pki_int/intermediate/generate/internal \
        common_name="VaultCA Intermediate Authority" \
        | jq -r '.data.csr' > pki_intermediate.csr
vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
        format=pem_bundle ttl="43800h" \
        | jq -r '.data.certificate' > intermediate.cert.pem
vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem

## Roleの作成  
vault write pki_int/roles/${CERT_DOMAIN} \
        allowed_domains="${CERT_DOMAIN}" \
        allow_subdomains=true \
        max_ttl="43800h"

## vault server certificate  

mv /etc/vault.d/cert /etc/vault.d/cert_bak
mkdir -p /etc/vault.d/cert

vault write pki_int/issue/${CERT_DOMAIN} common_name="${hostna}.${CERT_DOMAIN}" ip_sans="${ipaddr}" ttl="40000h" -format="json" > output
cat output | jq -r .data.certificate > /etc/vault.d/cert/vault.pem
cat output | jq -r .data.private_key > /etc/vault.d/cert/vault-key.pem
cat output | jq -r .data.ca_chain > /etc/vault.d/cert/ca-chain.crt.pem

## Vault CA crt download & update-ca
curl https://127.0.0.1:8200/v1/pki_int/ca/pem --insecure > intermediate.crt
cp intermediate.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust extract

## service restart
systemctl restart vault  
EOF


