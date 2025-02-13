#!/bin/bash

docker stop spring-petclinic
if docker rm spring-petclinic; then
  echo "removed previous version"
fi
docker run -d -p 80:8080 --name spring-petclinic adrwalacr.azurecr.io/spring-petclinic:${image_tag}
