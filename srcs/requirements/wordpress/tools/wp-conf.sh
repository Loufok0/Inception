#!/bin/bash

until mysqladmin ping -h"mariadb" --silent; do
	sleep 1
done

cd /var/www/wordpress

if ! wp core is-installed --allow-root; then
	wp core install \
		--url="${DOMAIN_NAME}" \
		--title="${SITE_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email \
		--allow-root
fi

if ! wp user get ${WP_USER} --allow-root > /dev/null 2>&1; then
	wp user create \
		${WP_USER} \
		${WP_USER_EMAIL} \
		--role=author \
		--user_pass=${WP_USER_PASSWORD} \
		--allow-root
fi

exec php-fpm8.2 -F

