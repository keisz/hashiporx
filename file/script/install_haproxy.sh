#!/bin/sh
set -e

#### haproxy install ############
yum install gcc pcre-devel tar make -y

curl http://www.haproxy.org/download/2.4/src/haproxy-2.4.0.tar.gz | tar zx
cd haproxy-2.4.0/
make clean
make TARGET=linux-glibc
make install

mkdir -p /etc/haproxy
mkdir -p /var/lib/haproxy 
touch /var/lib/haproxy/stats
ln -s /usr/local/sbin/haproxy /usr/sbin/haproxy
cp ~/haproxy/haproxy-2.4.0/examples/haproxy.init /etc/init.d/haproxy
chmod 755 /etc/init.d/haproxy
systemctl daemon-reload
chkconfig haproxy on
useradd -r haproxy

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-port=1936/tcp
firewall-cmd --reload

export NIC_NAME=$(nmcli -t con |cut -d ":" -f 1)
export IP_ADDRESS=$(ip -f inet -o addr show $NIC_NAME|cut -d\  -f 7 | cut -d/ -f 1)

echo $NIC_NAME
echo $IP_ADDRESS

cat <<EOF > /etc/haproxy/haproxy.cfg
global
   log /dev/log local0
   log /dev/log local1 notice
   chroot /var/lib/haproxy
   stats timeout 30s
   user haproxy
   group haproxy
   daemon

defaults
   log global
   mode http
   option httplog
   option dontlognull
   timeout connect 5000
   timeout client 50000
   timeout server 50000

frontend haproxy_stat_front
   bind *:1936
   stats uri /haproxy?stats
   default_backend http_back

backend haproxy_stat_back
   balance roundrobin
   server $HOSTNAME $IP_ADDRESS:1936 check
EOF

systemctl restart haproxy

##### haproxy sample nomad job ######
export NOMAD_ADDR=http://nomad.service.consul:4646

nomad job run ~/nomad_sample/job_sample/demo-webapp.nomad
sleep 5

##### haproxy.cfg config ##########

cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak

cat <<EOF >> /etc/haproxy/haproxy.cfg
frontend webapp_front
   bind *:8080
   default_backend webapp_back

backend webapp_back
    balance roundrobin
    server-template mywebapp 10 _demo-webapp._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

resolvers consul
  nameserver consul 127.0.0.1:8600
  accepted_payload_size 8192
  hold valid 5s
EOF

systemctl restart haproxy

firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload

