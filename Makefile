#
# Primary targets
#

up:
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs -f

.PHONY: up down logs

#
# MySQL related targets
#

mysql:
	docker-compose up mysql

mysql-prepare:
	docker exec -it "`docker ps -aqf "name=drupal_mysql"`" \
		mysql -p"`bash -c 'source ./etc/common.env && echo "$$MYSQL_ROOT_PASSWORD"'`" \
		-e "CREATE DATABASE IF NOT EXISTS drupal"
	docker exec -i  "`docker ps -aqf "name=drupal_mysql"`" \
		mysql -p"`bash -c 'source ./etc/common.env && echo "$$MYSQL_ROOT_PASSWORD"'`" \
		drupal < ./data/mysql-import/import.sql

mysql-client:
	docker exec -it "`docker ps -aqf "name=drupal_mysql"`" \
		mysql -p"`bash -c 'source ./etc/common.env && echo "$$MYSQL_ROOT_PASSWORD"'`"

.PHONY: mysql mysql-prepare mysql-client
