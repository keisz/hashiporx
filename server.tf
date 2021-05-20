###### Resource #########
resource "vsphere_virtual_machine" "vm_server" {
  count            = var.prov_vm_num_serv
   name            = "${var.prov_vmname_prefix_s}${format("%03d",count.index)}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

#Resource for VM Specs
  num_cpus = var.prov_cpu_num
  memory   = var.prov_mem_num
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
   
#portworx
  disk {
    label            = "disk0"
    size             = 100
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    unit_number      = 1
  }

 
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
        linux_options {
          host_name = "${var.prov_vmname_prefix_s}${format("%03d",count.index)}"
          domain    = var.pram_domain_name
        }        

        network_interface {
          ipv4_address = "${var.pram_ipv4_class}${count.index+var.pram_ipv4_host_serv}"
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
      source      = "file/script"
      destination = "~/script"
    }

  provisioner "remote-exec" {
    inline = [
      "yum install -y yum-utils",
      "yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo",
      # docker install
      "yum install -y device-mapper-persistent-data lvm2",
      "yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
      "yum install -y docker-ce docker-ce-cli containerd.io bash-completion",
      "systemctl start docker | systemctl enable docker",
      # app install
      "yum install -y consul jq bind-utils nomad vault dnsmasq git wget unzip",
      "consul -autocomplete-install && source $HOME/.bashrc",
      "nomad -autocomplete-install && source $HOME/.bashrc",
      "complete -C /usr/local/bin/nomad nomad",
      "vault -autocomplete-install && source $HOME/.bashrc",
      # fw consul
      "firewall-cmd --add-port=8300-8302/tcp --add-port=8400/tcp --add-port=8500/tcp --add-port=8600/tcp --permanent",
      "firewall-cmd --add-port=8301-8302/udp --add-port=8600/udp --permanent",
      ## dns masq
      "firewall-cmd --add-port=53/tcp --add-port=53/udp --permanent",
      # fw vault
      "firewall-cmd --add-port=8200/tcp --add-port=8201/tcp --permanent",
      # fw nomad
      "firewall-cmd --add-port=4646-4648/tcp --permanent",
      "firewall-cmd --add-port=4648/udp --permanent",
      # fw portworx on nomad
      "firewall-cmd --add-port=9001-9022/tcp --permanent",
      "firewall-cmd --add-port=9002/udp --permanent",
      # fw reload
      "firewall-cmd --reload",
      # conf consul
      "mkdir -p /etc/consul.d/cert/",
      "chmod +x ~/consul_sample/*.sh",
      "mv /etc/consul.d/consul.hcl /etc/consul.d/consul.hcl.org",
      # conf nomad
      "mv /etc/nomad.d/nomad.hcl /etc/nomad.d/nomad.hcl.org",
      # chmod +x script
      "chmod +x ~/script/*.sh",
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

  provisioner "file" {
      source      = "file/conf/nomad/nomad-server.hcl"
      destination = "/etc/nomad.d/nomad.hcl"
  }

  provisioner "file" {
      content     = "${data.template_file.resolv_dnsmasq[count.index].rendered}"
      destination = "/etc/resolv.dnsmasq.conf"
  }

}

