#!/bin/bash

set -e

DB_USER_PASSWORD=$(cat ${DATABASE_PASSWORD_FILE})
WP_USER_PASSWORD=$(cat ${WP_USER_PASSWORD_FILE})
WP_ADMIN_PASSWORD=$(cat ${WP_ADMIN_PASSWORD_FILE})

# Wait until mariadb is ready to accept connections *with the
# wordpress DB credentials*, not just until the port is open.
# docker-compose's depends_on only guarantees the mariadb
# container has started, not that the DB/user already exist.
until mysqladmin ping -h "${DATABASE_HOST}" -u "${DATABASE_USER}" -p"${DB_USER_PASSWORD}" --silent 2>/dev/null; do
	sleep 1
done

if [ ! -f "/var/www/html/wp-config.php" ]; then
	wp core download --path=/var/www/html --allow-root

	wp config create \
		--dbname=${DATABASE_NAME} \
		--dbuser=${DATABASE_USER} \
		--dbpass=${DB_USER_PASSWORD} \
		--dbhost=${DATABASE_HOST} \
		--path=/var/www/html \
		--allow-root

	wp core install \
		--url=https://${DOMAIN_NAME} \
		--title="${WP_TITLE}" \
		--admin_user=${WP_ADMIN_USER} \
		--admin_password=${WP_ADMIN_PASSWORD} \
		--admin_email=${WP_ADMIN_EMAIL} \
		--path=/var/www/html \
		--allow-root

	wp user create \
		${WP_USER} ${WP_USER_EMAIL} \
		--role=author \
		--user_pass=${WP_USER_PASSWORD} \
		--path=/var/www/html \
		--allow-root

	chown -R www-data:www-data /var/www/html

fi

# -F run in Foreground
exec php-fpm8.2 -F