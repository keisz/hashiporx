path "pki" {
  capabilities = [ "read" ]
}
path "pki/*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}