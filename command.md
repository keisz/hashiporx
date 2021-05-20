# command

## dev mode
`consul agent -dev`  

## auto complete  
`consul -autocomplete-install`  
インストール後にログオフ  

## consul サーバー/エージェントの確認  
`consul members`  

正確な情報を得る場合は curl で確認する  
`curl localhost:8500/v1/catalog/nodes`  


## DNSでノードの情報を検出  

`dig @127.0.0.1 -p 8600 consul-001.node.consul`  
*consul-001* はホスト名  

## 



