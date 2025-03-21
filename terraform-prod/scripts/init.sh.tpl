#!/bin/bash

# 1. Install docker
# Add Docker's official GPG key:
apt-get update
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

docker login -u ${acr_user} -p ${acr_pass} ${acr_url}

docker stop spring-petclinic
if docker rm spring-petclinic; then
  echo "removed previous version"
fi
docker run -d -p 80:8080 --name spring-petclinic adrwalacr.azurecr.io/spring-petclinic:${image_tag}
