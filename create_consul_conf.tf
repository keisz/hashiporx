###### consul.hcl template ######
data "template_file" "consul_server_conf" {
  count = var.prov_vm_num_serv 
  template = file("${path.module}/file/template/consul-server.tpl")

  vars = {
    vm0_ipaddr = vsphere_virtual_machine.vm_server[0].default_ip_address
    vm1_ipaddr = vsphere_virtual_machine.vm_server[1].default_ip_address
    vm2_ipaddr = vsphere_virtual_machine.vm_server[2].default_ip_address
    ipaddr     = vsphere_virtual_machine.vm_server[count.index].default_ip_address
  }
}

data "template_file" "consul_client_conf" {
  count = var.prov_vm_num_client  
  template = file("${path.module}/file/template/consul-client.tpl")

  vars = {
    vm0_ipaddr = vsphere_virtual_machine.vm_server[0].default_ip_address
    vm1_ipaddr = vsphere_virtual_machine.vm_server[1].default_ip_address
    vm2_ipaddr = vsphere_virtual_machine.vm_server[2].default_ip_address
    ipaddr     = vsphere_virtual_machine.vm_client[count.index].default_ip_address
  }
}

data "template_file" "vault_consul_client_conf" {
  count = var.prov_vm_num_va 
  template = file("${path.module}/file/template/consul-client.tpl")

  vars = {
    vm0_ipaddr = vsphere_virtual_machine.vm_server[0].default_ip_address
    vm1_ipaddr = vsphere_virtual_machine.vm_server[1].default_ip_address
    vm2_ipaddr = vsphere_virtual_machine.vm_server[2].default_ip_address
    ipaddr     = vsphere_virtual_machine.vm_vault[count.index].default_ip_address
  }
}

###### Consul cert file ######
data "template_file" "consul_server_cert" {
  count = var.prov_vm_num_serv 
  template = file("${path.module}/file/template/consul-cert-var.tpl")

  vars = {
    CERT_DOMAIN = var.pram_domain_name
    VAULT_SERVER = vsphere_virtual_machine.vm_vault[0].default_ip_address
  }
}

data "template_file" "consul_client_cert" {
  count = var.prov_vm_num_client 
  template = file("${path.module}/file/template/consul-cert-var.tpl")

  vars = {
    CERT_DOMAIN = var.pram_domain_name
    VAULT_SERVER = vsphere_virtual_machine.vm_vault[0].default_ip_address
  }
}

data "template_file" "vault_consul_client_cert" {
  count = var.prov_vm_num_va 
  template = file("${path.module}/file/template/consul-cert-var.tpl")

  vars = {
    CERT_DOMAIN = var.pram_domain_name
    VAULT_SERVER = vsphere_virtual_machine.vm_vault[0].default_ip_address
  }
}

###### Resource ######
resource "null_resource" "consul_server" {
  count = var.prov_vm_num_serv
  
  triggers = {
    cluster_instance_ids = join(",", vsphere_virtual_machine.vm_server.*.name)
  }

  connection {
    host      = element(vsphere_virtual_machine.vm_server.*.default_ip_address, count.index)
    type      = "ssh"
    user      = var.template_user
    password  = var.template_user_password
  }

  provisioner "remote-exec" {
    inline = [
      "${data.template_file.consul_server_conf[count.index].rendered}",
      "${data.template_file.consul_server_cert[count.index].rendered}",
    ]  
  }

  provisioner "file" {
      content     = "${data.template_file.resolv_dnsmasq[0].rendered}"
      destination = "/etc/resolv.dnsmasq.conf"
  }     
}

resource "null_resource" "consul_client" {
  count = var.prov_vm_num_client
  
  triggers = {
    cluster_instance_ids = join(",", vsphere_virtual_machine.vm_client.*.name)
  }

  connection {
    host      = element(vsphere_virtual_machine.vm_client.*.default_ip_address, count.index)
    type      = "ssh"
    user      = var.template_user
    password  = var.template_user_password
  }

  provisioner "remote-exec" {
    inline = [
      "${data.template_file.consul_client_conf[count.index].rendered}",
      "${data.template_file.consul_client_cert[count.index].rendered}",
    ]  
  } 

  provisioner "file" {
      content     = "${data.template_file.resolv_dnsmasq[0].rendered}"
      destination = "/etc/resolv.dnsmasq.conf"
  }   
}

resource "null_resource" "vault_consul_client" {
  count = var.prov_vm_num_va
  
  triggers = {
    cluster_instance_ids = join(",", vsphere_virtual_machine.vm_vault.*.name)
  }

  connection {
    host      = element(vsphere_virtual_machine.vm_vault.*.default_ip_address, count.index)
    type      = "ssh"
    user      = var.template_user
    password  = var.template_user_password
  }

  provisioner "remote-exec" {
    inline = [
      "${data.template_file.vault_consul_client_conf[count.index].rendered}",
      "${data.template_file.vault_consul_client_cert[count.index].rendered}",
    ]  
  }    
}
