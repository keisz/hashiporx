#vault setup parm 
data "template_file" "vaultpram" {
  count = var.prov_vm_num_va 
  template = file("${path.module}/file/template/vault_setup.tpl")

  vars = {
    ipaddr = "${var.pram_ipv4_class}${count.index+var.pram_ipv4_host_va}"   
  }
}

data "template_file" "vaultcert" {
  count = var.prov_vm_num_va 
  template = file("${path.module}/file/template/vault-server-cert.tpl")

  vars = {
    ipaddr = "${var.pram_ipv4_class}${count.index+var.pram_ipv4_host_va}"
    hostna = "${var.prov_vmname_prefix_va}${format("%03d",count.index)}"
    fqdn = "${var.prov_vmname_prefix_va}${format("%03d",count.index)}.${var.pram_domain_name}"    
  }
}

data "template_file" "vault_sh" {
  count = var.prov_vm_num_va 
  template = file("${path.module}/file/template/vault_sh.tpl")

  vars = {
    CERT_DOMAIN = var.pram_domain_name
    ipaddr = "${var.pram_ipv4_class}${count.index+var.pram_ipv4_host_va}"
    hostna = "${var.prov_vmname_prefix_va}${format("%03d",count.index)}"
  }
}

data "template_file" "resolv_dnsmasq" {
  count = var.prov_vm_num_va 
  template = file("${path.module}/file/template/resolv.dnsmasq.conf.tpl")

  vars = {
    DNS_SERVER = var.pram_dns_server
  }
}

####### Resource ########
resource "vsphere_virtual_machine" "vm_vault" {
  count            = var.prov_vm_num_va
   name            = "${var.prov_vmname_prefix_va}${format("%03d",count.index)}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

#Resource for VM Specs
  num_cpus = var.prov_cpu_num_va
  memory   = var.prov_mem_num_va
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network_1.id
    adapter_type = "vmxnet3"
  }

#Resource for Disks
  disk {
    label            = "disk1"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
   
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
        linux_options {
          host_name = "${var.prov_vmname_prefix_va}${format("%03d",count.index)}"
          domain    = var.pram_domain_name
        }        

        network_interface {
          ipv4_address = "${var.pram_ipv4_class}${count.index+var.pram_ipv4_host_va}"
          ipv4_netmask = var.pram_ipv4_subnet
        }
  
        ipv4_gateway    = var.pram_ipv4_gateway
        dns_server_list = [var.pram_dns_server]
    }
  }

  provisioner "file" {
      source      = "file/consul_sample"
      destination = "~/consul_sample"
    }
  
      connection {
      type      = "ssh"
      host      = self.default_ip_address
      user      = var.template_user
      password  = var.template_user_password
    }

  provisioner "file" {
      source      = "file/nomad_sample"
      destination = "~/nomad_sample"
    }

  provisioner "file" {
      source      = "file/vault_sample"
      destination = "~/vault_sample"
    }

  provisioner "file" {
      source      = "file/conf/cfssl"
      destination = "~/cfssl"
  }

  provisioner "file" {
      source      = "file/script"
      destination = "~/script"
  }

  provisioner "file" {
      source      = "file/conf/policy"
      destination = "~/policy"
  }

  provisioner "file" {
      content     = "${data.template_file.resolv_dnsmasq[count.index].rendered}"
      destination = "/etc/resolv.dnsmasq.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "setenforce 0",
      "yum install -y yum-utils",
      "yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo",
      # app install
      "yum install -y consul jq bind-utils nomad vault dnsmasq git wget unzip",
      "consul -autocomplete-install && source $HOME/.bashrc",
      "nomad -autocomplete-install && source $HOME/.bashrc",
      "vault -autocomplete-install && source $HOME/.bashrc",
      "curl -s -L -o /bin/cfssl https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssl_1.5.0_linux_amd64",
      "curl -s -L -o /bin/cfssljson https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssljson_1.5.0_linux_amd64",
      "curl -s -L -o /bin/cfssl-certinfo https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssl-certinfo_1.5.0_linux_amd644",
      "chmod +x /bin/cfssl*",
      # fw consul
      "firewall-cmd --add-port=8300-8302/tcp --add-port=8400/tcp --add-port=8500/tcp --add-port=8600/tcp --permanent",
      "firewall-cmd --add-port=8301-8302/udp --add-port=8600/udp --permanent",
      ## dns masq
      "firewall-cmd --add-port=53/tcp --add-port=53/udp --permanent",
      # fw vault
      "firewall-cmd --add-port=8200/tcp --add-port=8201/tcp --permanent",
      # fw reload
      "firewall-cmd --reload",
      # conf vault
      "mkdir -p /opt/vault/raft/",
      "chown -R vault:vault /opt/vault/raft/",
      "mv /etc/vault.d/vault.hcl /etc/vault.d/vault.hcl.org",
      "${data.template_file.vaultpram[count.index].rendered}",
      # cert
      "mkdir -p /etc/vault.d/cert",
      "${data.template_file.vaultcert[count.index].rendered}",
      "cd ~/cfssl",
      "cfssl gencert -config ~/cfssl/ca-config.json -profile root -initca ~/cfssl/ca-csr.json | cfssljson -bare ca",
      ##"cfssl gencert -ca=./ca.pem -ca-key=./ca-key.pem -config=~/cfssl/ca-config.json -hostname=${IP_ADDRESS},${HOSTNAME},vault.service.consul,localhost,127.0.0.1 -profile=hashiporx ./vault-csr.json | cfssljson -bare hashiporx",
      "cfssl gencert -ca ./ca.pem -ca-key ./ca-key.pem -config ~/cfssl/ca-config.json -profile hashiporx ~/cfssl/vault-csr.json | cfssljson -bare vault",
      ##"mkdir -p ~/script",
      "${data.template_file.vault_sh[count.index].rendered}",
      "cp ~/cfssl/ca.pem /etc/vault.d/cert/",
      "cp ~/cfssl/vault* /etc/vault.d/cert/",
      "chown -R vault:vault /etc/vault.d/",
      "systemctl restart vault",
      "systemctl enable vault",
      "cp ~/cfssl/ca.pem /usr/share/pki/ca-trust-source/anchors",
      "update-ca-trust extract",
      "chmod +x ~/script/vault/*.sh",
      "chmod +x ~/script/*",
    ]

    connection {
      type      = "ssh"
      host      = self.default_ip_address
      user      = var.template_user
      password  = var.template_user_password
    }
  }

  provisioner "file" {
      source      = "file/conf/10-consul.conf"
      destination = "/etc/dnsmasq.d/10-consul.conf"
  }
}

