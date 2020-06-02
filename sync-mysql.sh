#!/usr/bin/env zsh

0=${(%):-%N}
DIR=${0:A:h}

NAME=mariadb
MYSQL_ROOT_PASSWORD='super_secret_password'

typeset -a dbs
dbs=($(docker exec -i $NAME mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e 'SHOW DATABASES;' | grep MyVideos))
for db in $dbs; do
	docker exec -i $NAME mysql -uroot -p"$MYSQL_ROOT_PASSWORD" < <(sed "s/\[MyVideosDB\]/${db}/g" $DIR/watchedlist-sync.sql)
done
