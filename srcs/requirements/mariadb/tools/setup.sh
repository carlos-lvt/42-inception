#!/bin/bash

set -e

DB_ROOT_PASSWORD=$(cat ${DATABASE_ROOT_PASSWORD_FILE})
DB_USER_PASSWORD=$(cat ${DATABASE_PASSWORD_FILE})

chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
	mysqld_safe --skip-networking --datadir=/var/lib/mysql &

    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done
	
	mysql -u root <<-EOF
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS ${DATABASE_NAME};
    CREATE USER '${DATABASE_USER}'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${DATABASE_NAME}.* TO '${DATABASE_USER}'@'%';
    FLUSH PRIVILEGES;
EOF

	mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
fi

exec mysqld --user=mysql