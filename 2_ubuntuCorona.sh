#!/bin/bash

set -e

echo " "
echo "Тестирование докер"
echo "--------------------------------------------------------------"
id -nG
docker ps


echo " "
echo "Клонируем репозиторий Coronachess"
echo "--------------------------------------------------------------"

# Проверяем, существует ли директория ~/Dev
if [ ! -d "$HOME/Dev" ]; then
  mkdir "$HOME/Dev"
  echo "Директория ~/Dev успешно создана"
else
  echo "Директория ~/Dev уже существует"
fi

cd ~/Dev
git clone git@gitlab.com:cidious/coronachess.git

cd coronachess
git checkout dev

echo " "
echo "Установка Coronachess"
echo "--------------------------------------------------------------"

make start

echo "                                                              "
echo "Делаем запись в /etc/hosts"
echo "--------------------------------------------------------------"
if ! grep -q 'ccq.l.cidious.com' /etc/hosts; then
  local_ip=$(hostname -I | awk '{print $1}')
echo "$local_ip ccq.l.cidious.com grafana-ccq.l.cidious.com redis-ccq.l.cidious.com monitor.l.cidious.com dash-ccq.l.cidious.com pgadmin" | sudo tee -a /etc/hosts
fi

cat /etc/hosts

echo "--------------------------------------------------------------"
echo "Установка завершена успешно!"
echo "https://ccq.l.cidious.com/"
echo "--------------------------------------------------------------"
