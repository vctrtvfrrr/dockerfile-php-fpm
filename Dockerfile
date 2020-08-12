FROM php:7.4-fpm

LABEL maintainer="Victor Ferreira <victor@otavioferreira.com.br>"

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

#
#--------------------------------------------------------------------------
# Software's Installation
#--------------------------------------------------------------------------
#
# Installing tools and PHP extentions

RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
        apt-utils \
        libmemcached-dev \
        libz-dev \
        libmcrypt-dev \
        zlib1g-dev libicu-dev g++ \
        libjpeg-dev libpng-dev libfreetype6-dev jpegoptim optipng pngquant gifsicle ffmpeg \
        libmagickwand-dev imagemagick \
        libonig-dev \
        libzip-dev zip unzip \
        libldb-dev \
        libldap2-dev \
        libxml2-dev \
        libssl-dev \
        libxslt-dev \
        libpq-dev \
        libsqlite3-dev \
        libsqlite3-0 \
        libc-client-dev \
        libkrb5-dev \
        curl \
        libcurl4-gnutls-dev \
        libpspell-dev \
        aspell-en \
        aspell-pt \
        aspell-pt-br \
        libtidy-dev \
        libsnmp-dev \
        librecode0 \
        librecode-dev \
        libgmp-dev \
        libreadline-dev libedit-dev \
        libbz2-dev && \
    pecl channel-update pecl.php.net; \
    pecl install \
        # apcu \
        mcrypt-1.0.3 \
        xdebug \
        imagick && \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    # docker-php-ext-enable apcu && \
    docker-php-ext-enable xdebug && \
    docker-php-ext-enable imagick && \
    docker-php-ext-configure intl && \
    docker-php-ext-install -j$(nproc) intl && \
    docker-php-ext-configure gd --prefix=/usr --with-jpeg --with-freetype && \
    docker-php-ext-install -j$(nproc) gd && \
    docker-php-ext-install opcache && \
    docker-php-ext-install soap && \
    docker-php-ext-install ftp && \
    docker-php-ext-install xsl && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install calendar && \
    docker-php-ext-install ctype && \
    docker-php-ext-install dba && \
    docker-php-ext-install dom && \
    docker-php-ext-install zip && \
    docker-php-ext-install session && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu && \
    docker-php-ext-install ldap && \
    docker-php-ext-install json && \
    docker-php-ext-install sockets && \
    docker-php-ext-install pdo && \
    docker-php-ext-install mbstring && \
    docker-php-ext-install tokenizer && \
    docker-php-ext-install pgsql && \
    docker-php-ext-install pdo_pgsql && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install pdo_sqlite && \
    docker-php-ext-enable mcrypt && \
    docker-php-ext-install mysqli && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap && \
    docker-php-ext-install gd && \
    docker-php-ext-install curl && \
    docker-php-ext-install exif && \
    docker-php-ext-install fileinfo && \
    docker-php-ext-install gettext && \
    docker-php-ext-install gmp && \
    docker-php-ext-install iconv && \
    docker-php-ext-install opcache && \
    docker-php-ext-install pcntl && \
    docker-php-ext-install phar && \
    docker-php-ext-install posix && \
    docker-php-ext-install pspell && \
    docker-php-ext-install readline && \
    docker-php-ext-install shmop && \
    docker-php-ext-install simplexml && \
    docker-php-ext-install snmp && \
    docker-php-ext-install sysvmsg && \
    docker-php-ext-install sysvsem && \
    docker-php-ext-install sysvshm && \
    docker-php-ext-install tidy && \
    docker-php-ext-install xml && \
    docker-php-ext-install xmlrpc && \
    docker-php-ext-install xmlwriter && \
    docker-php-ext-install bz2

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

# Copy xdebug configuration for remote debugging
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
RUN sed -i "s/xdebug.remote_autostart=0/xdebug.remote_autostart=1/" /usr/local/etc/php/conf.d/xdebug.ini && \
    sed -i "s/xdebug.remote_enable=0/xdebug.remote_enable=1/" /usr/local/etc/php/conf.d/xdebug.ini && \
    sed -i "s/xdebug.cli_color=0/xdebug.cli_color=1/" /usr/local/etc/php/conf.d/xdebug.ini

###########################################################################
# Check PHP version:
###########################################################################

RUN set -xe; php -v | head -n 1 | grep -q "PHP 7.4."

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

COPY ./dev.ini /usr/local/etc/php/conf.d

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

# Configure non-root user.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data

WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000
