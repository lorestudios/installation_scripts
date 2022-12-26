#!/bin/bash

sudo echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDIpFS9mh1qIHa9trTjB9vQ/Oobh+drqx/k9a9ydW7fGy0ERE/YlC3SQvlRSurGuPULC+wc/x5dIVxBgkUQNDpNwdS2rXxPc55lCV5kpvUhaIyCsRlqLf+jby1JEPFzUsQbjPRl4ggR1eXyKwRG46wx0dRiwCdMgPVMdfNy7ckeYFQDkIAhZL5dWHQBTfr/ZWC8oTgGZ4hDEJHCDOTXY5HdM1M1DwX3EggrFM+zD8b/IO6Z+be4mbqDcA0rQl4GgBcggLz9fAf12kQiNw6ewVLSFlZsazphV8qonHUGpkxMpaKD1J+PhJNUxXoAsjCbvKlngIt28MaHppwQoXclG6AszpKQJJahrbZkupW0kOEKbJPUAmZt0KiJq0XZD6rhZqcFDo1V4e/3nlfDaXv/mee0+LIAprbiQEowB6YC1RZYvFlMZz1rgmZsIJieygGWB4J0xrvS2uBw++8peuninL2ZP+ORsm9yiFaKBgwZlqJ/NOWMZns+K9VlPIaSQS4ci+0= whetu@DESKTOP-NVTCV4R" >> /home/debian/.ssh/authorized_keys
sudo echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYdxVDc6tCaVW8n7zeYnmHDnse20GUuEWZC07dtRxNGr7Pp1ry0r2in63jkFNbsYzp6X5dmmSOJMc1+oac06WM6vUeqaOuQNx7qnV3gIcVdObEkFWP6wdFMXH7658HT9okOCQZ1/Nt8+vdWJsqInWk//LcH2h9Rfu6nM5NjsYwLObXu7KKggzPKvFHEtAlfkE9vOskKY1s6sLkOCV/Aaa7HmfaMG9zV8LwsQpQ4kA3AdfS0DZA+/jzbi7UNRmVSRJWYMeEGUZ1NZI6BakYK162pzqGwdXlAM0sYAJx3iVOarFCpQZgOj/eyQWj+bdffgvP3JtEpRDemQUHnxpcoCzhcAv+REgaiT8xBlskx/8+TA8WqUYjGEzZKdUDauAsU1xGKPVMszyJ7oPCBjr8hxNc1mlWF6AYE+jSirmhFz7w4rsRP6bv2J3AxDVTKGeiy8UIgSK/GZ453uQEbuxZlCZz6lcUS48gjCyf4o/fzQMN6gYt+qX37UdsnJv/a5u/Yb0= piki" >> /home/debian/.ssh/authorized_keys

sudo apt upgrade -y
sudo apt update

sudo sed -i 's/#AddressFamily\ any/AddressFamily\ inet/g' /etc/ssh/sshd_config
sudo sed -i 's/#Port\ 22/Port\ 8572/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin\ prohibit-password/PermitRootLogin\ no/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo apt -y install ufw
sudo ufw allow 8572
sudo ufw allow http
sudo ufw allow https
sudo ufw --force enable

sudo apt install fail2ban -y
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo sed -i 's/=\ ssh/=\ 8572/g' /etc/fail2ban/jail.local
sudo service fail2ban restart

sudo apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt update

sudo apt -y install docker-ce docker-ce-cli containerd.io

sudo curl -L "https://github.com/docker/compose/releases/download/v2.14.1/docker-compose-$(uname -s)-$(uname -m)"  -o /usr/local/bin/docker-compose
sudo mv /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose

sudo groupadd docker
sudo usermod -aG docker debian
newgrp docker

sudo mkdir /home/debian/web
sudo curl https://raw.githubusercontent.com/lorestudios/docker-compose-web/main/compose -o /home/debian/web/docker-compose.yml
sudo docker network create web
sudo docker-compose -f /home/debian/web/docker-compose.yml up -d --force-recreate --remove-orphans
