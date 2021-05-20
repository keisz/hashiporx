#!/bin/sh
set -e

## set variable
chmod +x ~/script/consul-cert-var.sh
source ~/script/consul-cert-var.sh

## vault pram
VAULT_TOKEN=$(vault login -tls-skip-verify -method=userpass username=user password=password -format=json | jq -r .auth.client_token)

## create cert
mkdir -p /etc/consul.d/cert/
cd /etc/consul.d/cert/

curl -X PUT -H "X-Vault-Request: true" -H "X-Vault-Token: $VAULT_TOKEN" -d '{"common_name": "'$HOSTNAME.$DC_NAME.$DOMAIN_NAME'" ,"ip_sans":"'$IP_ADDRESS',127.0.0.1","ttl":"40000h"}' $VAULT_ADDR/v1/pki/issue/$DOMAIN_NAME --insecure  > output

cat output | jq -r .data.certificate > server_crt.pem
cat output | jq -r .data.private_key > private_key.pem

curl $VAULT_ADDR/v1/pki/ca/pem --insecure > /etc/consul.d/cert/ca.crt

