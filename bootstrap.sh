#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

set -xeu
apt-get update -y
# Instalar herramientas que aceleran el resto del proceso
apt-get install -y zstd curl wget

echo "deb http://deb.debian.org/debian bullseye main" | sudo tee /etc/apt/sources.list.d/bullseye.list
apt-get update -y
apt-get install -y openjdk-11-jdk
apt install -y tomcat9 tomcat9-admin

groupadd tomcat9
useradd -s /bin/false -g tomcat9 -d /etc/tomcat9 tomcat9

cp /vagrant/context.xml /usr/share/tomcat9-admin/host-manager/META-INF/context.html
cp /vagrant/tomcat-users.xml /etc/tomcat9/tomcat-users.xml

apt-get update && sudo apt-get -y install maven

systemctl start tomcat9
systemctl status tomcat9
systemctl restart tomcat9

mvn --v