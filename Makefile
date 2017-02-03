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

MYSQL_ROOT_PASSWORD:
	$(eval MYSQL_ROOT_PASSWORD := $(shell bash -c 'source ./etc/mysql.env && echo "$$MYSQL_ROOT_PASSWORD"'))

MYSQL_DOCKER_ID:
	$(eval MYSQL_DOCKER_ID := $(shell docker ps -aqf "name=drupal_mysql"))

MYSQL_DATABASE:
	$(eval MYSQL_DATABASE := $(shell bash -c 'source ./etc/common.env && echo "$$MYSQL_DATABASE"'))

MYSQL_USER:
	$(eval MYSQL_USER := $(shell bash -c 'source ./etc/common.env && echo "$$MYSQL_USER"'))

MYSQL_PASS:
	$(eval MYSQL_PASS := $(shell bash -c 'source ./etc/common.env && echo "$$MYSQL_PASS"'))

mysql:
	docker-compose up mysql

mysql-prepare: MYSQL_DOCKER_ID MYSQL_ROOT_PASSWORD MYSQL_DATABASE MYSQL_USER MYSQL_PASS
	docker exec -it "${MYSQL_DOCKER_ID}" \
		mysql -p"${MYSQL_ROOT_PASSWORD}" \
		-e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE}"
	docker exec -it "${MYSQL_DOCKER_ID}" \
		mysql -p"${MYSQL_ROOT_PASSWORD}" \
		-e "GRANT ALL ON ${MYSQL_DATABASE}.* to ${MYSQL_USER}@'%' identified by '${MYSQL_PASS}'"
	docker exec -i "${MYSQL_DOCKER_ID}" \
		mysql -p"${MYSQL_ROOT_PASSWORD}" \
		drupal < ./data/mysql-import/import.sql

mysql-client: MYSQL_DOCKER_ID MYSQL_ROOT_PASSWORD
	docker exec -it "${MYSQL_DOCKER_ID}" \
		mysql -p"${MYSQL_ROOT_PASSWORD}"

.PHONY: MYSQL_DOCKER_ID MYSQL_ROOT_PASSWORD MYSQL_DATABASE MYSQL_USER MYSQL_PASS
.PHONY: mysql mysql-prepare mysql-client
