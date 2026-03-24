FROM wordpress:latest

# Install MariaDB and supervisor
RUN apt-get update && apt-get install -y \
    mariadb-server \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
ENV WP_CLI_ALLOW_ROOT=1
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# Ensure MariaDB run directory exists
RUN mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld

# Copy Once integration mu-plugin
COPY mu-plugins/ /opt/once/mu-plugins/

# Copy configuration and scripts
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /once-entrypoint.sh
COPY up.php /var/www/html/up.php
COPY hooks/ /hooks/

RUN chmod +x /once-entrypoint.sh /hooks/*

EXPOSE 80

ENTRYPOINT ["/once-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
