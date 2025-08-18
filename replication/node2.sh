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
mkdir -p /log/relaylog
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

# Start MariaDB in the background temporarily
echo "Starting temporary MariaDB instance..."
gosu mysql mariadbd --skip-networking --socket=/var/lib/mysql/mysql.sock &
pid=$!

# Wait for MariaDB to start
sleep 10

# Start MariaDB temporarily as 'mysql' user to create replication user
echo "Configuring replication..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -S /var/lib/mysql/mysql.sock <<-EOSQL
STOP SLAVE;
RESET SLAVE ALL;
CHANGE MASTER TO
  MASTER_HOST='10.1.0.10',
  MASTER_USER='replicator',
  MASTER_PASSWORD='password',
  MASTER_LOG_FILE='mariadb-bin.000008',
  MASTER_LOG_POS=344,
  MASTER_CONNECT_RETRY=10;
START SLAVE;
EOSQL

# Stop temporary server
echo "Stopping temporary MariaDB..."
mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" -S /var/lib/mysql/mysql.sock shutdown
wait "$pid" || true

# Start the main MariaDB process as the 'mysql' user
echo "Starting MariaDB..."
exec gosu mysql "$@"