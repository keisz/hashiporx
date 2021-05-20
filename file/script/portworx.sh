#!/bin/sh
set -e

# Add nomad-client parm
cat <<EOF > /etc/nomad.d/portworx.hcl
plugin "docker" {
  config {
    endpoint = "unix:///var/run/docker.sock"

    volumes {
      enabled      = true
      selinuxlabel = "z"
    }

    allow_privileged = true
  }
}
EOF

chown nomad:nomad /etc/nomad.d/portworx.hcl 

systemctl restart nomad

