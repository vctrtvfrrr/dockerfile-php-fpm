FROM devilbox/php-fpm-8.0:latest

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
    curl \
    libbz2-dev \
    libtidy-dev \
    libxslt-dev \
    libldap2-dev \
    libsqlite3-dev \
    libsqlite3-0 \
    libc-client-dev \
    libkrb5-dev \
    libpq-dev \
    libjpeg-dev libpng-dev libfreetype6-dev jpegoptim optipng pngquant gifsicle ffmpeg \
    libmagickwand-dev imagemagick \
    libzip-dev zip unzip && \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    docker-php-ext-configure intl && \
    docker-php-ext-configure gd --with-jpeg --with-freetype && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install -j$(nproc) \
    bcmath bz2 exif gd gettext imap intl ldap mysqli opcache \
    pdo_mysql pdo_sqlite pdo_pgsql pgsql soap sockets tidy xsl zip

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

WORKDIR /var/www

# Configure non-root user.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data && \
    chown -R www-data:www-data /var/www

CMD ["php-fpm"]

EXPOSE 9000
