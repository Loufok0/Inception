#!/bin/bash

# socket dir
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

mysqld_safe --datadir=/var/lib/mysql &

# wait for mariadb
until mysqladmin ping --silent; do
    sleep 1
done

# if no db then init it
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Initialisation de la base de données..."
    mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
else
    echo "Data base already exist so skipping installation"
    mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
fi

exec mysqld_safe

