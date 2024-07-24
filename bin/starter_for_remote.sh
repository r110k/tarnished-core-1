#!/bin/bash
function title {
  echo
  echo "################################################################################"
  echo "## $1"
  echo "################################################################################"
  echo
}

function set_env {
  name=$1
  hint=$2
  [[ ! -z "${!name}" ]] && return
  while [ -z "${!name}" ]; do
    [[ ! -z "$hint" ]] && echo "🤖 > 请输入 $name: $hint" || echo "🤖 > 请输入 $name"
    read $name
  done
  sed -i "1s/^/export $name=${!name}\n/" ~/.bashrc
}
user=tarnished-user
dir=tarnishedcore-1
root=/home/$user/workspace/$dir/deploys/$version
container_name=tarnishedcore-prod
db_container_name=tarnishedcore-dbproxy
nginx_container_name=tarnished-niginx

echo '📦 READY TO STARTER!'

title '🐧 设置远程机器环境变量'
set_env DB_HOST
set_env DB_PASSWORD
set_env RAILS_MASTER_KEY '🪅 请将 config/credentials/production.key 的内容复制到这里'

echo '🙋‍♂️ Checking database ...'
if [ ! -z "$(docker ps -aq -f name=^tarnishedcore-dbproxy$)" ]; then
  title '🔕 已经有数据库了'
else
  title '👜 创建数据库'
  docker run -d --name $DB_HOST \
            --network=network1 \
            -e POSTGRES_USER=tarnishedcore \
            -e POSTGRES_DB=tarnishedcore_prod \
            -e POSTGRES_PASSWORD=$DB_PASSWORD \
            -e PGDATA=/var/lib/postgresql/data/pgdata \
            -v tarnishedcore-data:/var/lib/postgresql/data \
            -p 5432:5432 \
            postgres:14
  title '🐾 创建数据库成功'
fi

title '👀 APP: Docker build ...'
docker build $root -t tarnishedcore:$version

echo '🙋‍♂️ APP: Checking container ...'
if [ ! -z "$(docker ps -aq -f name=^tarnishedcore-prod$)" ]; then
  title '🚫 APP: 删除正在运行的老容器'
  docker rm -f $container_name
fi
title '🙋‍♂️ APP: Docker run ...'
docker run -d -p 3000:3000 \
            --name=$container_name \
            --network=network1 \
            -e RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
            -e DB_HOST=$DB_HOST \
            -e DB_PASSWORD=$DB_PASSWORD \
            tarnishedcore:$version

title '⏏️ 是否要更新数据库?[y/N]'
read ans
case $ans in
  y|Y|1 ) echo 'yes'; title '🔴 执行更新数据库...'; docker exec $container_name bin/rails db:create db:migrate ;;
  n|N|2 ) echo 'no';;
  "" ) echo 'no';;
esac

title "🧸 DOC: docker run"
docker rm -f $nginx_container_name
docker run -d -p 9010:80 \
            --network=network1 \
            --name=$nginx_container_name \
            -v $root/api:/usr/share/nginx/html:ro \
            nginx:latest

echo '🤟🏼 STARTER DONE!'
