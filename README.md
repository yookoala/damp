# Docker AMP Stack

Docker based Apache, MariaDB, PHP stack.

## Setup

### Import and Setup MySQL

If you want to initialize your database, please:

1. Copy your SQL dump file to ./data/mysql-import/import.sql

2. Run this:
    ```
    make mysql mysql-prepare
    ```

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
