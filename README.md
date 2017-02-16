# Docker AMP Stack

Docker based Apache, MariaDB, PHP stack.


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

### B. Import and Setup MySQL

If you want to initialize your database, please:

1. Copy your SQL dump file to ./data/mysql-import/import.sql

2. Run this:
    ```
    make mysql mysql-prepare
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

## Usage

(Finish me)

make up
make down
make logs

### Connect to MySQL CLI

If you want to connect the mysql with CLI client, run this:

```
make mysql-cli
```
