#Variable
##Define Variables for Platform
variable "vsphere_user" {}           #vsphereのユーザー名
variable "vsphere_password" {}       #vsphereのパスワード
variable "vsphere_vc_server" {}         #vCenterのFQDN/IPアドレス
variable "vsphere_datacenter" {}     #vsphereのデータセンター
variable "vsphere_datastore" {}      #vsphereのデータストア
variable "vsphere_cluster" {}        #vsphereのクラスター
variable "vsphere_network_1" {}        #vsphereのネットワーク
variable "vsphere_resource_pool" {}  #ResourcePool名
variable "vsphere_template_name" {}  #プロビジョニングするテンプレート

##OS Template User / Password  
variable "template_user" {}           #OSテンプレートに設定されているOSユーザー名
variable "template_user_password" {}  #OSテンプレートに設定されているOSユーザーのパスワード

##Network param
variable "pram_domain_name" {}         #仮想マシンが参加するドメイン名
variable "pram_ipv4_subnet" {}         #仮想マシンのネットワークのサブネット
variable "pram_ipv4_gateway" {}        #仮想マシンのネットワークのデフォルトゲートウェイ
variable "pram_dns_server" {}          #仮想マシンが参照するDNSサーバー
variable "pram_ipv4_class" {}          #利用できるクラスCの値を指定
variable "pram_ipv4_host_serv" {}      #プロビジョニングする仮想マシンに割り当てるIPアドレスの最初の値
variable "pram_ipv4_host_client" {}    #プロビジョニングする仮想マシンに割り当てるIPアドレスの最初の値
variable "pram_ipv4_host_va" {}        #Vaultノード用のIP

##Define Variables for Virtual Machines
variable "prov_vm_num_serv" {}       #プロビジョニングする仮想マシンの数
variable "prov_vm_num_client" {}     #プロビジョニングする仮想マシンの数
variable "prov_vmname_prefix_s" {}     #プロビジョニングする仮想マシンの接頭語
variable "prov_vmname_prefix_c" {}     #プロビジョニングする仮想マシンの接頭語
variable "prov_cpu_num" {}           #プロビジョニングする仮想マシンのCPUの数
variable "prov_mem_num" {}           #プロビジョニングする仮想マシンのメモリのMB

##VaultServer
variable "prov_vm_num_va" {}            #プロビジョニングする仮想マシンの数
variable "prov_vmname_prefix_va" {}     #プロビジョニングする仮想マシンの接頭語
variable "prov_cpu_num_va" {}           #プロビジョニングする仮想マシンのCPUの数
variable "prov_mem_num_va" {}           #プロビジョニングする仮想マシンのメモリのMB

