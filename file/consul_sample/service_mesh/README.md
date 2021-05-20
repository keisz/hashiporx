# consul service mesha sample

元ネタ: https://github.com/hashicorp/demo-consul-101  

golang 環境が必須になっている。バイナリがダウンロードできるので、バイナリを利用して実行する  

[counting-service_linux_amd64.zip](https://github.com/hashicorp/demo-consul-101/releases/download/0.0.3.1/counting-service_linux_amd64.zip)

[dashboard-service_linux_amd64.zip](https://github.com/hashicorp/demo-consul-101/releases/download/0.0.3.1/dashboard-service_linux_amd64.zip)

unzipがない場合はインストールする `yum install -y unzip` 

```
yum install -y unzip
mkdir servicemesh
cd servicemesh
curl -LO https://github.com/hashicorp/demo-consul-101/releases/download/0.0.3.1/counting-service_linux_amd64.zip
curl -LO https://github.com/hashicorp/demo-consul-101/releases/download/0.0.3.1/dashboard-service_linux_amd64.zip

unzip counting-service_linux_amd64.zip
unzip dashboard-service_linux_amd64.zip
```

## このバイナリはなにか？
golangで書かれたWebサーバー。  
変数 *PORT* でListenのポートを指定することができる  

```
PORT=9100 ./counting-service_linux_amd64
PORT=9200 ./dashboard-service_linux_amd64
```





