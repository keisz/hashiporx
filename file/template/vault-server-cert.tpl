cat <<-EOF > ~/cfssl/vault-csr.json
{
    "CN": "${hostna}",
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "JP",
        "L": "Tokyo",
        "O": "hashiporx",
        "OU": "AA",
        "ST": "ST"
      }
    ],
    "hosts": [
      "${hostna}",
      "${fqdn}",
      "vault.service.consul",
      "${ipaddr}",
      "127.0.0.1",
      "localhost"
    ]
}
EOF