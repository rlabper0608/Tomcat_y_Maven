#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

set -xeu
apt-get update -y
# Instalar herramientas que aceleran el resto del proceso
apt-get install -y zstd curl wget

echo "deb http://deb.debian.org/debian bullseye main" | sudo tee /etc/apt/sources.list.d/bullseye.list
apt-get update -y
apt-get install -y openjdk-11-jdk
apt install -y tomcat9 tomcat9-admin git

getent group tomcat9 >/dev/null || groupadd tomcat9
getent passwd tomcat9 >/dev/null || useradd -s /bin/false -g tomcat9 -d /etc/tomcat9 tomcat9

cp /vagrant/context.xml /usr/share/tomcat9-admin/host-manager/META-INF/context.html
cp /vagrant/tomcat-users.xml /etc/tomcat9/tomcat-users.xml

apt-get update && sudo apt-get -y install maven

cp /vagrant/settings.xml /etc/maven/settings.xml

systemctl start tomcat9
systemctl status tomcat9
systemctl restart tomcat9

mvn --v
rm -rf tomcat-war

mvn archetype:generate -DgroupId=org.zaidinvergeles \
                         -DartifactId=tomcat-war \
                         -Ddeployment \
                         -DarchetypeArtifactId=maven-archetype-webapp \
                         -DinteractiveMode=false

cp /vagrant/pom.xml /home/vagrant/tomcat-war/pom.xml
chown -R vagrant:vagrant /home/vagrant/tomcat-war

rm -rf rock-paper-scissors

git clone https://github.com/cameronmcnz/rock-paper-scissors.git
cd rock-paper-scissors
git checkout patch-1
cd ..
cp /vagrant/pom-juego.xml /home/vagrant/rock-paper-scissors/pom.xml
chown -R vagrant:vagrant /home/vagrant/rock-paper-scissors

# 1. Desplegar la aplicación de prueba (tomcat-war)
cd /home/vagrant/tomcat-war
sudo -u vagrant mvn tomcat7:redeploy

# 2. Desplegar el juego (rock-paper-scissors)
cd /home/vagrant/rock-paper-scissors
sudo -u vagrant mvn tomcat7:redeploy