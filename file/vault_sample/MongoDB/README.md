# MongoDB Secret Engine  
https://learn.hashicorp.com/tutorials/vault/database-mongodb?in=vault/new-release


## docker install 
yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install -y docker-ce docker-ce-cli containerd.io bash-completion
systemctl start docker
systemctl enable docker

curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
curl -L https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose

echo $(docker version)

## mongdb 実行

docker run -d \
    -p 0.0.0.0:27017:27017 -p 0.0.0.0:28017:28017 \
    --name=mongodb \
    -e MONGO_INITDB_ROOT_USERNAME="mdbadmin" \
    -e MONGO_INITDB_ROOT_PASSWORD="hQ97T9JJKZoqnFn2NXE" \
    mongo






