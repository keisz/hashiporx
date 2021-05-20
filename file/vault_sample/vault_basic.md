# vault 基本操作  
Vaultを操作するために必要な基本操作です。  

## 事前準備  
vault server上での操作を前提として、**VAULT_ADDR** に vault serverのIPアドレスをセットします。  

### Terraformによるvault serverデプロイ直後（HTTP）
```
IP_ADDRESS=$(ip -f inet -o addr show ens192|cut -d\  -f 7 | cut -d/ -f 1)
export VAULT_ADDR=http://$IP_ADDRESS:8200
```

### Vault ServerをHTTPS化した場合
```
IP_ADDRESS=$(ip -f inet -o addr show ens192|cut -d\  -f 7 | cut -d/ -f 1)
export VAULT_ADDR=https://$IP_ADDRESS:8200
```

## vault operator init
vault serverの初期化です。vault server 初回起動後に1度だけ実施します。  
後述の**unseal**につかうkeyや **root token** がこのコマンドの出力で表示されます。  

```
cd ~/vault_sample
vault operator init -format json > vaultkey
```

## vault unseal
vaultのサービス再起動やOS再起動を行った際に実施する作業です。Vaultは起動直後は seal 状態となっていて、vaultサーバーにアクセスができない状態になっています。**useal**を行うことでVaultを利用できるようになります。
*vault operator init* で出力されたアウトプットが **vaultkey** にあるので、その中から unsealに利用するkeyを変数に割り当て、Unsealを実行します。    

- vaultkeyがあるディレクトリで実施

```
cd ~/vault_sample
export unseal_key1=$(cat vaultkey | jq -r .unseal_keys_b64[0])
export unseal_key2=$(cat vaultkey | jq -r .unseal_keys_b64[1])
export unseal_key3=$(cat vaultkey | jq -r .unseal_keys_b64[2])

vault operator unseal $unseal_key1
vault operator unseal $unseal_key2
vault operator unseal $unseal_key3
```

## vault root token set
*vault operator init* で出力されたアウトプットの **vaultkey**から root tokenを変数に割り当て、ログインします。

- vaultkeyがあるディレクトリで実施

```
cd ~/vault_sample
export ROOT_TOKEN=$(cat vaultkey | jq -r .root_token)
export VAULT_TOKEN=$ROOT_TOKEN
vault login $VAULT_TOKEN
```

## Secret の一覧  
`vault secrets list`  
`vault secrets list -detailed`  

## 認証プロバイダ(?)の一覧
`vault auth list`
`vault auth list -detailed`

