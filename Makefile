#
# Variables
#
MYSQL_IMPORT_FILE := "./var/mysql-import/import.sql"


#
# Primary targets
#

up: httpd-php-all
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs -f

.PHONY: up down logs


#
# Environment files
#

env: etc/common.env etc/mysql.env

etc/common.env:
	cp -pdf ./etc/common.env.example ./etc/common.env

etc/mysql.env:
	cp -pdf ./etc/mysql.env.example ./etc/mysql.env

.PHONY: env


#
# PHP Version specific setup
#

up-php54: httpd-php-clean httpd-php54
	docker-compose up -d php54-fpm

up-php55: httpd-php-clean httpd-php55
	docker-compose up -d php55-fpm

up-php56: httpd-php-clean httpd-php56
	docker-compose up -d php56-fpm

up-php70: httpd-php-clean httpd-php70
	docker-compose up -d php70-fpm

up-php71: httpd-php-clean httpd-php71
	docker-compose up -d php71-fpm


#
# HTTPD and config connecting to PHP-FPM
#

httpd:
	docker-compose up -d httpd

httpd-php-all: httpd-php54 httpd-php55 httpd-php56 httpd-php70 httpd-php71

httpd-php-clean:
	find ./etc/httpd/sites-enabled/. -type l -exec rm -f "{}" \;

httpd-php54: etc/httpd/sites-enabled/php54.conf

etc/httpd/sites-enabled/php54.conf:
	cd ./etc/httpd/sites-enabled && ln -s ../sites-available/php54.conf

httpd-php55: etc/httpd/sites-enabled/php55.conf

etc/httpd/sites-enabled/php55.conf:
	cd ./etc/httpd/sites-enabled && ln -s ../sites-available/php55.conf

httpd-php56: etc/httpd/sites-enabled/php56.conf

etc/httpd/sites-enabled/php56.conf:
	cd ./etc/httpd/sites-enabled && ln -s ../sites-available/php56.conf

httpd-php70: etc/httpd/sites-enabled/php70.conf

etc/httpd/sites-enabled/php70.conf:
	cd ./etc/httpd/sites-enabled && ln -s ../sites-available/php70.conf

httpd-php71: etc/httpd/sites-enabled/php71.conf

etc/httpd/sites-enabled/php71.conf:
	cd ./etc/httpd/sites-enabled && ln -s ../sites-available/php71.conf

.PHONY: httpd-php-all httpd-php-clean
.PHONY: httpd-php54 httpd-php55 httpd-php56 httpd-php70


#
# MySQL related targets
#

MYSQL_DOCKER_ID:
	$(eval MYSQL_DOCKER_ID := $(shell docker-compose ps -q "mysql"))

MYSQL_ROOT_PASSWORD:
	$(eval MYSQL_ROOT_PASSWORD := $(shell bash -c 'source ./etc/mysql.env && echo "$$MYSQL_ROOT_PASSWORD"'))

MYSQL_DATABASE:
	$(eval MYSQL_DATABASE := $(shell bash -c 'source ./etc/common.env && echo "$$MYSQL_DATABASE"'))

MYSQL_USER:
	$(eval MYSQL_USER := $(shell bash -c 'source ./etc/common.env && echo "$$MYSQL_USER"'))

MYSQL_PASS:
	$(eval MYSQL_PASS := $(shell bash -c 'source ./etc/common.env && echo "$$MYSQL_PASS"'))

mysql:
	docker-compose up -d mysql

mysql-ping: MYSQL_DOCKER_ID MYSQL_ROOT_PASSWORD MYSQL_DATABASE MYSQL_USER MYSQL_PASS
	docker exec -it "${MYSQL_DOCKER_ID}" \
		mysql -p"${MYSQL_ROOT_PASSWORD}" \
		-e "SELECT 1"

mysql-ping-wait:
	@echo "Try to connect to MySQL"
	@for c in $$(seq 1 10); do \
	  make --quiet mysql-ping 2>&1 > /dev/null && break; \
	  echo "- failed. wait 5 seconds for retry."; sleep 5; \
	done
	@echo "- connection success"

mysql-prepare: MYSQL_DOCKER_ID MYSQL_ROOT_PASSWORD MYSQL_DATABASE MYSQL_USER MYSQL_PASS
ifeq ($(shell test -e "${MYSQL_IMPORT_FILE}" && echo -n yes),yes)
	make mysql-ping-wait
	docker exec -it "${MYSQL_DOCKER_ID}" \
		mysql -p"${MYSQL_ROOT_PASSWORD}" \
		-e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE}"
	docker exec -it "${MYSQL_DOCKER_ID}" \
		mysql -p"${MYSQL_ROOT_PASSWORD}" \
		-e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE}"
	docker exec -it "${MYSQL_DOCKER_ID}" \
		mysql -p"${MYSQL_ROOT_PASSWORD}" \
		-e "GRANT ALL ON ${MYSQL_DATABASE}.* to ${MYSQL_USER}@'%' identified by '${MYSQL_PASS}'"
	docker exec -i "${MYSQL_DOCKER_ID}" \
		mysql -p"${MYSQL_ROOT_PASSWORD}" \
		${MYSQL_DATABASE} < "${MYSQL_IMPORT_FILE}"
else
	@echo "'${MYSQL_IMPORT_FILE}' does not exist. skip mysql-import."
endif

mysql-cli: MYSQL_DOCKER_ID MYSQL_ROOT_PASSWORD
	docker exec -it "${MYSQL_DOCKER_ID}" \
		mysql -p"${MYSQL_ROOT_PASSWORD}"

.PHONY: MYSQL_DOCKER_ID MYSQL_ROOT_PASSWORD MYSQL_DATABASE MYSQL_USER MYSQL_PASS
.PHONY: mysql mysql-ping mysql-ping-wait mysql-prepare mysql-cli
