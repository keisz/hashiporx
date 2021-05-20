# Vault Sampleの使い方  
vault_sampleではVaultの機能を試すためのスクリプトや設定ファイル（HCLファイル）を用意しています。  


## 基本操作
[vault_basic.md](vault_basic.md) を参照  

## インストール後に使い始めるまで  
[vault_start.md](vault_start.md) を参照  
vault serverのサーバー証明書をvault server自身がCAとなり自己署名証明書を発行し適用します。


## 操作ユーザーの作成  
Vaultのインストール段階では **root token** を利用して操作権限を取得します。  
ベストプラクティスで **root token** の利用は推奨されていないので操作用のadmin ユーザーを作成します。  

```
cd ~/vault_sample/
chmod +x auth_userpass.sh
chmod +x admin-user-policy.sh
./auth_userpass.sh
./admin-user-policy.sh
```




