#!/bin/bash

set -e

echo " "
echo "Настройка паролей"
echo "--------------------------------------------------------------"
# чтоб не спрашивал пароль при sudo
sudo bash -c 'echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-nopasswd'

# чтоб не ждал подтверждения при установке
export DEBIAN_FRONTEND=noninteractive
if [ -f /etc/needrestart/needrestart.conf ]; then
  sudo sed -i '/\$nrconf{restart}/s/^#//g' /etc/needrestart/needrestart.conf
  sudo sed -i "/nrconf{restart}/s/'i'/'a'/g" /etc/needrestart/needrestart.conf
else
  sudo mkdir -p /etc/needrestart
  echo '$nrconf{restart}' = \'a\'';' > nrconf
  sudo cp nrconf /etc/needrestart/needrestart.conf
  rm nrconf
fi

# чтоб не спрашивал authenticity of host gitlab.com
mkdir -p ~/.ssh
chmod 0700 ~/.ssh
echo -e "Host gitlab.com\n   StrictHostKeyChecking no\n   UserKnownHostsFile=/dev/null" > ~/.ssh/config

echo " "
echo "Предварительное удаление старых версий докер"
echo "--------------------------------------------------------------"
# удаляем всё ненужное
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done


echo " "
echo "Вручную добавить пароль '-ssh' в скрипт 1_ubuntuDocker.sh, пауза 10 сек"
echo "--------------------------------------------------------------"
sleep 10
# Check if the .ssh directory exists, and create it if it doesn't
ssh_dir="$HOME/.ssh"
if [ ! -d "$ssh_dir" ]; then
    mkdir "$ssh_dir"
fi

chmod 700 "$ssh_dir"

# сюда добавить пароль от архива
unzip -P  -d "$HOME" archive.zip

chmod 600 "$ssh_dir/id_rsa.pub"
chmod 600 "$ssh_dir/authorized_keys"

# добавляем ключ для докера
sudo rm -f /etc/apt/keyrings/docker.gpg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# добавляем докеровский реп
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "                                                              "
echo "Устанавливаем docker и системные приложения"
echo "--------------------------------------------------------------"
sudo apt update -y
sudo apt-get install samba samba-common samba-libs mc tmux zsh mosh curl wget ca-certificates net-tools gpg gnupg nodejs npm make yarn apt-transport-https ca-certificates net-tools docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin gawk m4 libpcre3-dev libxerces-c-dev libspdlog-dev libuchardet-dev libssh-dev libssl-dev libsmbclient-dev libnfs-dev libneon27-dev libarchive-dev cmake g++ -y


echo " "
echo "Установка докер-композ"
echo "--------------------------------------------------------------"
# ставим Docker Compose
if [ ! -f /usr/local/bin/docker-compose ]; then
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-`uname -s`-`uname -m`" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

echo " "
echo "Установка far2l"
echo "--------------------------------------------------------------"
# ставим far2l
if [ ! -d ~/far2l ]; then
  cd
  rm -f ~/far2l || true
  git clone https://github.com/elfmz/far2l
  mkdir -p far2l/_build
  cd far2l/_build
  cmake -DUSEWX=no -DCMAKE_BUILD_TYPE=Release -DEACP=no -DPYTHON=no ..
  cmake --build . -j$(nproc --all)
  sudo cmake --install .
fi

echo " "
echo "Установка lazydocker"
echo "--------------------------------------------------------------"
# Get the latest version tag of Lazydocker release from GitHub
LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"

mkdir lazydocker-temp
tar xf lazydocker.tar.gz -C lazydocker-temp
sudo mv lazydocker-temp/lazydocker /usr/local/bin
rm -rf lazydocker.tar.gz lazydocker-temp
lazydocker --version

echo " "
echo "Редактируем настройки samba"
echo "--------------------------------------------------------------"

sudo mkdir /samba
sudo mkdir /samba/share
sudo chown -R $USER:$USER /samba/share

#установка пароля на доступ к диску
(echo 321321; echo 321321) | sudo smbpasswd -s -a $USER

#права на чтение логов
sudo usermod -a -G adm corona
sudo chgrp -R adm /var/log/samba
sudo chmod -R g+r /var/log/samba

#конфиг диска
sudo tee /etc/samba/smb.conf <<EOF 
[global]
   workgroup = WORKGROUP
   server string = %h
   dns proxy = no
   log level = 2
   log file = /var/log/samba/log.%m
   max log size = 1000
   panic action = /usr/share/samba/panic-action %d
   ntlm auth = yes
   server role = standalone server
   passdb backend = smbpasswd:/etc/samba/smbpasswd
   obey pam restrictions = no
   unix password sync = no
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes
   map to guest = bad user
   socket options = TCP_NODELAY
   usershare allow guests = yes
[printers]
   comment = All Printers
   browseable = no
   path = /var/spool/samba
   printable = yes
   guest ok = no
   read only = yes
   create mask = 0700
[print$]
   comment = Printer Drivers
   path = /var/lib/samba/printers
   browseable = yes
   read only = yes
   guest ok = no
[homes]
   comment = Home Directories
    printable=no
    create mask=0664
    directory mask=0775
    browseable = yes
    guest ok=no
    writeable=yes
    hosts allow=ALL
    valid users = %S
EOF

sudo systemctl daemon-reload
sudo systemctl enable smbd
sudo systemctl start smbd

echo " "
echo "Редактируем конфиг netplan, проверяйте"
echo "--------------------------------------------------------------"

sudo tee /etc/netplan/00-installer-config.yaml <<EOF 
network:
  ethernets:
    enp0s3:
      addresses: 
        - 192.168.1.160/24
      dhcp4: false
      nameservers:
          addresses: [1.1.1.1]
      routes:
        - to: 0.0.0.0/0
          via: 192.168.1.1
  version: 2
EOF

sleep 5

# Применяем измененный конфиг 
sudo netplan apply


echo " "
echo "Создание группы docker. Потребуется перезагрузка!"
echo "--------------------------------------------------------------"
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo gpasswd -a $USER docker


echo '-------------------------------------------------------------------'
echo '---------------------- REBOOT IN 10 SEC ----------------------------'
echo '-------------------------------------------------------------------'
sleep 10
sudo reboot

