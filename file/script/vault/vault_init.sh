#!/bin/sh
set -e

export VAULT_ADDR=https://127.0.0.1:8200

vault operator init -format json > ~/vaultkey

chmod +x ~/script/vault/*.sh
~/script/vault/vault_unseal.sh
sleep 10
~/script/vault/vault_login.sh
sleep 5
~/script/vault/vault.sh

