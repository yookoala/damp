# Documentation for DAMP

## Requirements

This stack requires the below software to run

 * [Make][gnumake]
 * [Docker][docker]
 * [Docker Compose][docker-compose]

[docker]: https://www.docker.com/
[docker-compose]: https://docs.docker.com/compose/
[gnumake]: https://www.gnu.org/software/make/

To install them on Ubuntu 16.04+, the following command should do the job:

```bash
sudo apt update
sudo apt upgrade
sudo apt install -y docker make
curl -L "https://github.com/docker/compose/releases/download/1.10.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

To verify the requirements:

```bash
make --version
docker --version
docker-compose --version
```

## Setup

Before using the stack, you need to follow through the setup steps below.

### A. Setup Environment

All containers in this stack share some common variables defined in `.env`
files. First you need to setup basic environment variables:

```
make env
```

You may edit the generated files afterwards:

 * `./etc/common.env`
 * `./etc/mysql.env`

### B. Import and Setup MariaDB

If you want to initialize your database, please:

1. Copy your SQL dump file to `./var/mysql-import/import.sql`

2. Run this:
    ```
    make mysql mysql-prepare
    ```

### C. Setup Configs

To use preset configurations
```
make httpd-php-all
```

To clear up previous configs
```
make httpd-php-clean
```

If you want to do it yourself, simply add your virtual host configurations in
this folder:

  * [./etc/httpd/sites-enabled](etc/httpd/sites-enabled).

### D. Place your source into document root

All hosted file should be in:

 * [./var/www/html](var/www/html)

It will be mapped in PHP and Apache dockers as `/var/www/html`.


## Usage

### Start All the Services

```
make up
```

The Apache will be bind to port 8080 of your machine

### Start Specific PHP Version

To start HTTPD with just 1 of the PHP, use these commands:

 * `make up.php54` for php-5.4
 * `make up.php55` for php-5.5
 * `make up.php56` for php-5.6
 * `make up.php70` for php-7.0
 * `make up.php71` for php-7.1

### Accessing the Sites

To access the sites, you can open your browser and open these domains:

* [php54.damp.localhost:8080](http://php54.damp.localhost:8080)
* [php55.damp.localhost:8080](http://php55.damp.localhost:8080)
* [php56.damp.localhost:8080](http://php56.damp.localhost:8080)
* [php70.damp.localhost:8080](http://php70.damp.localhost:8080)
* [php71.damp.localhost:8080](http://php71.damp.localhost:8080)

### Checking the PHP Version

All default Apache configurations alias the path `/phpinfo` to the common
script [phpinfo.php](var/www/common/phpinfo.php). In case you're not sure if
you're using the desired version, you may check that path.

### Stop All the Services

```
make down
```

### See Service Logs

```
make logs
```

### Connect to MariaDB CLI

If you want to connect the mariadb with CLI client, run this:

```
make mysql-cli
```

## Special Use Case

You may use environment variables directly in your config file. Here are some
examples.

### Drupal Config

```php

$databases = array (
  'default' =>
  array (
    'default' =>
    array (
      'database' => $_ENV['MYSQL_DATABASE'],
      'username' => $_ENV['MYSQL_USER'],
      'password' => $_ENV['MYSQL_PASS'],
      'host' => $_ENV['MYSQL_HOST'],
      'port' => $_ENV['MYSQL_PORT'],
      'driver' => 'mysql',
      'prefix' => '',
    ),
  ),
);

```


## Extending the Stack

To add new PHP version to the stack, you need to:

1. Define a new docker file. (i.e. `./dockers/php[version].dockerfile`). You may
   reference other files in the [dockers folder](dockers).

2. Add a new [docker-compose.yml](docker-compose.yml) definition for the new
   PHP version. You may reference sections of other php versions.

3. Add a new virtual host config to [sites-available](etc/httpd/sites-available)
   folder. You should follow the naming convention and name it as
   `php[version].conf`. You may reference other files in the same folder.

Afterwards, these commands are already supporting your newly added php version:

```
make up
make down
make httpd-php-all
make httpd-php-clean
```

You may also use the following command for free:

```
make etc/httpd/sites-enabled/php[version].conf
make up.php[version]
make down.php[version]
```
