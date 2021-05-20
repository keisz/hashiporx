cat <<-EOF > /etc/consul.d/consul.hcl
# Full configuration options can be found at https://www.consul.io/docs/agent/options.html

# datacenter
datacenter = "dc1"

# data_dir
data_dir = "/opt/consul"

# client_addr
client_addr = "0.0.0.0"

# bind_addr
bind_addr = "${ipaddr}"

# ui
ui = true

# server
server = true

# bootstrap_expect
bootstrap_expect=3

# encrypt
# `consul keygen` 
#encrypt = "..."
encrypt = "JRiVmOeTZm6GcpTrC9Bago2Y7f6qFTfY2svb39bn7A0=" 

# tls
ca_file = "/etc/consul.d/cert/ca.crt"
cert_file = "/etc/consul.d/cert/server_crt.pem"
key_file = "/etc/consul.d/cert/private_key.pem"

# retry_join
retry_join = ["${vm0_ipaddr}" , "${vm1_ipaddr}" , "${vm2_ipaddr}"]

# If set to true, Consul requires all incoming/outgoing connections to use TLS
verify_incoming = true
verify_outgoing = true

# If set to true, Consul verifies for all outgoing TLS connections that the TLS certificate presented 
# by the servers matches server.<datacenter>.<domain> hostname.
#verify_server_hostname = true

# Auto Encription Method
auto_encrypt {
  allow_tls = true
}

enable_local_script_checks = true
EOF

chown -R consul:consul /etc/consul.d