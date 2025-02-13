#!/bin/bash

docker stop spring-petclinic
if docker rm spring-petclinic; then
  echo "removed previous version"
fi
docker run -d -p 80:8080 --name spring-petclinic -e MYSQL_URL=jdbc:mysql://${mysql_fqdn}/petclinic -e MYSQL_USER=${mysql_user} -e MYSQL_PASS=${mysql_pass} adrwalacr.azurecr.io/spring-petclinic:${image_tag} -jar /app.jar --spring.profiles.active=mysql
