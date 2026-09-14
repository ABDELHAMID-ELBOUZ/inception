#!/bin/bash
set -e

MYSQL_HOST="mariadb"

echo "Waiting for MariaDB at ${MYSQL_HOST}..."
until mysqladmin ping -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent 2>/dev/null; do
    sleep 2
done
echo "MariaDB is ready."

cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress core..."
    wp core download --allow-root --path=/var/www/html

    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="${MYSQL_HOST}" \
        --allow-root \
        --path=/var/www/html

    echo "Installing WordPress..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --allow-root \
        --path=/var/www/html

    echo "Creating second user..."
    wp user create \
        "${WORDPRESS_USER}" \
        "${WORDPRESS_USER_EMAIL}" \
        --role=author \
        --user_pass="${WORDPRESS_USER_PASSWORD}" \
        --allow-root \
        --path=/var/www/html

    echo "WordPress installation complete."
fi

exec php-fpm8.2 -F