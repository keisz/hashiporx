#!/bin/sh
set -e

# unseal
export unseal_key1=$(cat ~/vaultkey | jq -r .unseal_keys_b64[0])
export unseal_key2=$(cat ~/vaultkey | jq -r .unseal_keys_b64[1])
export unseal_key3=$(cat ~/vaultkey | jq -r .unseal_keys_b64[2])

vault operator unseal $unseal_key1
vault operator unseal $unseal_key2
vault operator unseal $unseal_key3
