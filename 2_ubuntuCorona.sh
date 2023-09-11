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

echo "--------------------------------------------------------------"
echo "Установка завершена успешно!"
echo "https://ccq.l.cidious.com/"
echo "--------------------------------------------------------------"
