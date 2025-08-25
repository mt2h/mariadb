#!/bin/bash
set -e

# Set ownership and permissions for all directories and data
echo "Setting directory ownership..."
chown -R mysql:mysql /data
chown -R mysql:mysql /log
chown -R mysql:mysql /backup
chown -R mysql:mysql /tools
chown -R mysql:mysql /var/log/mariadb

# Ensure log directories exist
mkdir -p /log/binlog
mkdir -p /var/log/mariadb
touch /var/log/mariadb/mariadb.log
chown -R mysql:mysql /log /var/log/mariadb

if [ ! -d "/data/mysql" ]; then
    echo "Initializing database in /data..."
    mysql_install_db --user=mysql --datadir=/data
fi

# Start Chrony in the background
echo "Starting Chrony..."
chronyd -d -f /etc/chrony/chrony.conf &

# Wait for Chrony to synchronize
sleep 2

# Start MariaDB temporarily as 'mysql' user to create replication user
echo "Starting MariaDB temporarily to create replication user..."
gosu mysql mysqld --skip-networking --skip-bind-address &
pid="$!"
sleep 5  # wait until MariaDB is ready

# Create replication user if it doesn't exist
echo "Creating replication user if not exists..."
mysql -u root -S /var/lib/mysql/mysql.sock <<-EOSQL
-- Replication user
CREATE USER IF NOT EXISTS 'replicator'@'%' IDENTIFIED BY 'password';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
-- Monitor user for MaxScale
CREATE USER IF NOT EXISTS 'monitor'@'%' IDENTIFIED BY 'password';
GRANT REPLICATION CLIENT ON *.* TO 'monitor'@'%';
GRANT SUPER, RELOAD, PROCESS, SHOW DATABASES, EVENT ON *.* TO 'monitor'@'%';
-- Apply changes
FLUSH PRIVILEGES;
EOSQL

# Stop temporary server
echo "Stopping temporary MariaDB..."
mysqladmin -u root -S /var/lib/mysql/mysql.sock shutdown
wait "$pid" || true

# Start the main MariaDB process as the 'mysql' user
echo "Starting MariaDB..."
exec gosu mysql "$@"