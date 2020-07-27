FROM php:7.4-fpm

LABEL maintainer="Victor Ferreira <victor@otavioferreira.com.br>"

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

#
#--------------------------------------------------------------------------
# Software's Installation
#--------------------------------------------------------------------------
#
# Installing tools and PHP extentions using "apt", "docker-php" and "pecl"
RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
            apt-utils \
            curl \
            libmemcached-dev \
            libz-dev \
            libpq-dev \
            libjpeg-dev \
            libpng-dev \
            libfreetype6-dev \
            libssl-dev \
            libmcrypt-dev \
            libonig-dev \
            libzip-dev zip unzip \
            libbz2-dev \
            libxslt-dev \
            zlib1g-dev libicu-dev g++; \
    pecl channel-update pecl.php.net; \
    pecl install xdebug && \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    # Install the PHP mysqli extention
    docker-php-ext-install mysqli && \
    # Install the PHP pdo_mysql extention
    docker-php-ext-install pdo_mysql && \
    # Install the PHP pgsql extension
    docker-php-ext-install pgsql && \
    # Install the PHP pdo_pgsql extention
    docker-php-ext-install pdo_pgsql && \
    # Install the PHP gd extension
    docker-php-ext-configure gd  --prefix=/usr --with-jpeg --with-freetype; \
    docker-php-ext-install gd && \
    # Install the PHP zip extension
    docker-php-ext-configure zip; \
    docker-php-ext-install zip && \
    # Install the PHP bz2 extension
    docker-php-ext-install bz2 && \
    # Install the PHP xsl extension
    docker-php-ext-install xsl && \
    # Enable the xDebug extension
    docker-php-ext-enable xdebug && \
    # Install the PHP bcmath extension
    docker-php-ext-install bcmath && \
    # Install the PHP exif extension
    docker-php-ext-install exif && \
    # Install the PHP intl extension
    docker-php-ext-configure intl; \
    docker-php-ext-install intl

# Copy xdebug configuration for remote debugging
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
RUN sed -i "s/xdebug.remote_autostart=0/xdebug.remote_autostart=1/" /usr/local/etc/php/conf.d/xdebug.ini && \
    sed -i "s/xdebug.remote_enable=0/xdebug.remote_enable=1/" /usr/local/etc/php/conf.d/xdebug.ini && \
    sed -i "s/xdebug.cli_color=0/xdebug.cli_color=1/" /usr/local/etc/php/conf.d/xdebug.ini
