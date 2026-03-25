# Grab WordPress core files to seed the first boot
FROM wordpress:latest AS seed

FROM php:8.3-fpm-alpine

# Install runtime dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    mariadb \
    mariadb-client \
    openssl \
    curl \
    bash \
    freetype \
    libjpeg-turbo \
    libpng \
    libwebp \
    libzip \
    icu-libs

# Install PHP extensions needed by WordPress
RUN apk add --no-cache --virtual .build-deps \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libzip-dev \
        icu-dev \
        $PHPIZE_DEPS \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        exif \
        gd \
        intl \
        mysqli \
        opcache \
        zip \
    && apk del .build-deps

# PHP configuration
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# WP-CLI
ENV WP_CLI_ALLOW_ROOT=1
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# MariaDB configuration and directories
COPY mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
RUN mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld

# WordPress seed (only used on first boot, then auto-updates take over)
COPY --from=seed /usr/src/wordpress /usr/src/wordpress

# Once integration files
COPY mu-plugins/ /opt/once/mu-plugins/
COPY up.php /opt/once/up.php

# Configuration and scripts
COPY nginx.conf /etc/nginx/http.d/default.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /once-entrypoint.sh
COPY hooks/ /hooks/

RUN chmod +x /once-entrypoint.sh /hooks/*

EXPOSE 80

ENTRYPOINT ["/once-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
