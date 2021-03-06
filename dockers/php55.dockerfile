FROM php:5.5-fpm

# custom folder for common configurations
VOLUME /usr/local/etc/damp.d
ENV PHP_INI_SCAN_DIR=:/usr/local/etc/damp.d

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install iconv mcrypt pdo_mysql mbstring \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

CMD ["php-fpm"]
