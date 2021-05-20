#!/bin/sh
set -e

chown nomad:nomad /etc/nomad.d/nomad.hcl 

systemctl start nomad
systemctl enable nomad