# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/debian-9"
  config.vm.provision :shell, privileged: true, inline: <<-EOF
    #!/bin/sh

    DIST=$(. /etc/os-release; echo "$ID")
    RELEASE=$(lsb_release -cs)

    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common

    curl -fsSL "https://download.docker.com/linux/${DIST}/gpg" | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/${DIST} ${RELEASE} stable"
    apt-get update
    apt-get install -y docker-ce

    systemctl stop docker
    gpasswd -a vagrant docker
    systemctl enable docker
    systemctl start docker
  EOF
end
