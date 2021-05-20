cat <<-EOF > /etc/vault.d/vault.hcl
storage "raft" {
  path    = "/opt/vault/raft/"
  node_id = "node1"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_cert_file = "/etc/vault.d/cert/vault.pem"
  tls_key_file  = "/etc/vault.d/cert/vault-key.pem"
}

ui = true
disable_mlock = true
api_addr = "http://${ipaddr}:8200"
cluster_addr = "http://${ipaddr}:8201"
EOF

