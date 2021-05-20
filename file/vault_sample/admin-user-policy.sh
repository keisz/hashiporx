#!/bin/sh
set -e

## vault login
cd ~/vault_sample/
export ROOT_TOKEN=$(cat ../vaultkey | jq -r .root_token)
export VAULT_TOKEN=$ROOT_TOKEN
IP_ADDRESS=$(ip -f inet -o addr show ens192|cut -d\  -f 7 | cut -d/ -f 1)
export VAULT_ADDR=https://$IP_ADDRESS:8200
export VAULT_TOKEN=$ROOT_TOKEN
vault login $VAULT_TOKEN

## create vault policy
vault policy write admin-policy admin-policy.hcl

## create admin user
vault write auth/userpass/users/admin1 password=password policies=admin-policy

echo "username: admin1"
echo "password: password"
echo "ログインテストは下記のコマンドで実行"
echo "IP_ADDRESS=$(ip -f inet -o addr show ens192|cut -d\  -f 7 | cut -d/ -f 1)"
echo "export VAULT_ADDR=https://$IP_ADDRESS:8200"
echo "vault login -method=userpass username=admin1 password=password"





