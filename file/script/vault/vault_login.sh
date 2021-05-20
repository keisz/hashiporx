#!/bin/sh
set -e

# vault login
export VAULT_TOKEN=$(cat ~/vaultkey | jq -r .root_token)
export IP_ADDRESS=$(ip -f inet -o addr show ens192|cut -d\  -f 7 | cut -d/ -f 1)
export VAULT_ADDR=https://$IP_ADDRESS:8200
vault login $VAULT_TOKEN
