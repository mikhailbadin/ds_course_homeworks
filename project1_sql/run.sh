#!/bin/sh
export POSGRES_HOST=localhost
export POSGRES_PORT=12345

# 1. Запускаем docker контейнер с postgres внутри с которой будем работать.
echo '== Запускаем docker контейнер =='
sudo docker-compose --project-name postgres-db -f ./docker/docker-compose.yml up --build -d

# 2. Загружаем данные в БД в docker контейнер
echo '== Загружаем данные в БД =='
./scripts/load_data.sh ./data/ $POSGRES_HOST $POSGRES_PORT

# 3. Выполняем запросы в БД
echo '== Выполняем запросы в БД =='
psql --host $POSGRES_HOST --port $POSGRES_PORT -U postgres -a -f ./scripts/requests.sql

# 4. Выполняем ipython notebook
export PANDAS_EXPORT_FOLDER="$PWD/out/"
jupyter-notebook ./scripts/requests.ipynb

