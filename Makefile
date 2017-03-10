#
# Variables
#
MYSQL_IMPORT_FILE := "./var/mysql-import/import.sql"


#
# Primary targets
#

up: var/www/html httpd-php-all env
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs -f

clean: down httpd-php-clean env-clean

clean-all: clean var-clean

var/www/html:
	mkdir var/www/html

.PHONY: up down logs clean clean-all


#
# var folder management
#

var-clean: down
	sudo rm -Rf var/logs/*
	sudo rm -Rf var/mysql/*

.PHONY: var-clean


#
# Environment files
#

env:
	for name in ./etc/*.env.example; do \
	  printf '%s\0' "$${name%.example}"; \
	done | xargs -0 make

env-clean:
	rm -f etc/*.env

etc/%.env:
	cp -pdf "./etc/${*}.env.example" "./etc/${*}.env"

.PHONY: env


#
# PHP Version specific setup
#

%.up: var/www/html httpd-php-clean etc/httpd/sites-enabled/%.conf env
	docker-compose up -d ${*}-fpm

%.down:
	docker-compose stop ${*}-fpm httpd
	docker-compose rm -f ${*}-fpm

httpd.up:
	docker-compose up -d httpd

httpd.down:
	docker-compose stop httpd
	docker-compose rm -f httpd

mysql.up:
	docker-compose up -d mysql

mysql.down:
	docker-compose stop mysql
	docker-compose rm -f mysql

.PHONY: %.up %.down
.PHONY: httpd.up httpd.down
.PHONY: mysql.up mysql.down


#
# HTTPD and config connecting to PHP-FPM
#

httpd-php-all:
	for name in ./etc/httpd/sites-available/*.conf; do \
	  printf "etc/httpd/sites-enabled/%s\0" "$${name#./etc/httpd/sites-available/}"; \
	done | xargs -0 make

httpd-php-clean:
	find ./etc/httpd/sites-enabled/. -type l -exec rm -f "{}" \;

etc/httpd/sites-enabled/%.conf:
ifeq ($(wildcard "./etc/httpd/sites-available/$*.conf"),)
	cd ./etc/httpd/sites-enabled && ln -s ../sites-available/$*.conf
else
	@echo "failed to make 'etc/httpd/sites-enabled/$*.conf':"
	@echo " - source file 'etc/httpd/sites-available/$*.conf' not found."
	@exit 1
endif

.PHONY: httpd-php-all httpd-php-clean


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

mysql-cli: MYSQL_DOCKER_ID MYSQL_ROOT_PASSWORD MYSQL_DATABASE
	docker exec -it "${MYSQL_DOCKER_ID}" \
		mysql -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}"

.PHONY: MYSQL_DOCKER_ID MYSQL_ROOT_PASSWORD MYSQL_DATABASE MYSQL_USER MYSQL_PASS
.PHONY: mysql-ping mysql-ping-wait mysql-prepare mysql-cli
