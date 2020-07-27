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
            ; \
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
    # Install the PHP gd library
    docker-php-ext-configure gd  --prefix=/usr --with-jpeg --with-freetype; \
    docker-php-ext-install gd && \
    # Install the PHP zip library
    docker-php-ext-configure zip; \
    docker-php-ext-install zip && \
    # Install the PHP bz2 library
    docker-php-ext-install bz2 && \
    # Install the PHP xsl library
    docker-php-ext-install xsl
