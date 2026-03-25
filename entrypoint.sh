#!/bin/bash
set -e

STORAGE_DIR="/storage"
DB_DATA_DIR="${STORAGE_DIR}/db/mysql"
WP_DIR="${STORAGE_DIR}/wordpress"
CONFIG_DIR="${STORAGE_DIR}/config"
DB_PASSWORD_FILE="${CONFIG_DIR}/.db_password"
WP_PATH="/var/www/html"

# ── Storage Setup ──────────────────────────────────────────────
mkdir -p "${DB_DATA_DIR}" "${CONFIG_DIR}"

# ── Database Password ─────────────────────────────────────────
if [ ! -f "${DB_PASSWORD_FILE}" ]; then
    openssl rand -hex 16 > "${DB_PASSWORD_FILE}"
fi
chmod 600 "${DB_PASSWORD_FILE}"
DB_PASSWORD=$(cat "${DB_PASSWORD_FILE}")

# ── MariaDB Setup ─────────────────────────────────────────────
chown -R mysql:mysql "${DB_DATA_DIR}"
mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

if [ ! -d "${DB_DATA_DIR}/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --datadir="${DB_DATA_DIR}" --user=mysql --skip-test-db
fi

# Start MariaDB temporarily for setup
mariadbd --datadir="${DB_DATA_DIR}" --user=mysql --skip-networking &
TMPDB_PID=$!

echo "Waiting for MariaDB..."
for i in $(seq 1 30); do
    if mariadb-admin ping --silent 2>/dev/null; then
        break
    fi
    sleep 1
done

# Create database and user
mariadb -u root <<-EOSQL
    CREATE DATABASE IF NOT EXISTS wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'127.0.0.1' IDENTIFIED BY '${DB_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

# Stop temporary MariaDB
mariadb-admin -u root shutdown
wait "${TMPDB_PID}" 2>/dev/null || true

# ── WordPress Core ────────────────────────────────────────────
if [ ! -f "${WP_DIR}/wp-includes/version.php" ]; then
    echo "Downloading WordPress..."
    mkdir -p "${WP_DIR}"
    wp core download --path="${WP_DIR}"
fi

# Serve WordPress from the persistent volume
rm -rf "${WP_PATH}"
ln -sf "${WP_DIR}" "${WP_PATH}"

# ── Once Integration ─────────────────────────────────────────
mkdir -p "${WP_DIR}/wp-content/mu-plugins"
cp /opt/once/mu-plugins/*.php "${WP_DIR}/wp-content/mu-plugins/"
cp /opt/once/up.php "${WP_DIR}/up.php"

# ── wp-config.php ─────────────────────────────────────────────
if [ ! -f "${CONFIG_DIR}/wp-config.php" ]; then
    echo "Generating wp-config.php..."

    generate_salt() { openssl rand -base64 48 | tr -d '\n/+=' | head -c 64; }

    cat > "${CONFIG_DIR}/wp-config.php" <<WPEOF
<?php
/** WordPress configuration — managed by Once */

// Database
define('DB_NAME',     'wordpress');
define('DB_USER',     'wordpress');
define('DB_PASSWORD', '${DB_PASSWORD}');
define('DB_HOST',     '127.0.0.1');
define('DB_CHARSET',  'utf8mb4');
define('DB_COLLATE',  '');

// Authentication keys and salts
define('AUTH_KEY',         '$(generate_salt)');
define('SECURE_AUTH_KEY',  '$(generate_salt)');
define('LOGGED_IN_KEY',    '$(generate_salt)');
define('NONCE_KEY',        '$(generate_salt)');
define('AUTH_SALT',        '$(generate_salt)');
define('SECURE_AUTH_SALT', '$(generate_salt)');
define('LOGGED_IN_SALT',   '$(generate_salt)');
define('NONCE_SALT',       '$(generate_salt)');

\$table_prefix = 'wp_';

// SSL — Once terminates TLS at the reverse proxy
if (getenv('DISABLE_SSL')) {
    define('FORCE_SSL_ADMIN', false);
} else {
    define('FORCE_SSL_ADMIN', true);
    if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
        \$_SERVER['HTTPS'] = 'on';
    }
}

// Auto-updates — keep WordPress current without rebuilding the image
define('WP_AUTO_UPDATE_CORE', true);
define('FS_METHOD', 'direct');

define('WP_DEBUG', false);

if (!defined('ABSPATH')) {
    define('ABSPATH', '/var/www/html/');
}

require_once ABSPATH . 'wp-settings.php';
WPEOF
fi

ln -sf "${CONFIG_DIR}/wp-config.php" "${WP_DIR}/wp-config.php"

# ── Permissions ───────────────────────────────────────────────
chown -R www-data:www-data "${WP_DIR}"
chown www-data:www-data "${CONFIG_DIR}/wp-config.php"
chmod 640 "${CONFIG_DIR}/wp-config.php"

echo "WordPress is ready. Starting services..."
exec "$@"
