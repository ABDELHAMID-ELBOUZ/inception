#!/bin/bash
set -e

mkdir -p /var/run/mysqld
chown -R  mysql:mysql /var/run/mysqld

if [ ! -d /var/lib/mysql/$MYSQL_DATABASE ]; then
	echo "Initializing MariaDB..."
	mariadb-install-db  --user=mysql --datadir=/var/lib/mysql > /dev/null

	mariadbd --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
EOF

	echo "MariaDB initialized!"
fi

exec mariadbd -u mysql