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

# Wait until Chrony is synchronized
echo "Waiting for Chrony to synchronize..."
until chronyc tracking | grep -q "Leap status     : Normal"; do
  sleep 1
done

echo "Chrony is synchronized!"

# Start MariaDB in the background temporarily
echo "Starting temporary MariaDB instance..."
gosu mysql mariadbd --skip-networking --socket=/var/lib/mysql/mysql.sock &
pid=$!

# Wait until node1 (master) is available
until mysql -h 10.1.0.10 -u monitor -ppassword -S /var/lib/mysql/mysql.sock -e "SELECT 1;" &>/dev/null; do
  echo "Waiting for master to be ready..."
  sleep 2
done

# Fetch master status dynamically
echo "Fetching master binlog position from node1..."
MASTER_STATUS=$(mysql -h 10.1.0.10 -u monitor -ppassword -S /var/lib/mysql/mysql.sock -e "SHOW MASTER STATUS\G")
MASTER_LOG_FILE=$(echo "$MASTER_STATUS" | grep File: | awk '{print $2}')
MASTER_LOG_POS=$(echo "$MASTER_STATUS" | grep Position: | awk '{print $2}')

echo "Master log file: $MASTER_LOG_FILE"
echo "Master log pos : $MASTER_LOG_POS"

MASTER_GTID=$(mysql -h 10.1.0.10 -u monitor -ppassword -S /var/lib/mysql/mysql.sock \
  -N -B -e "SELECT BINLOG_GTID_POS('$MASTER_LOG_FILE', $MASTER_LOG_POS);" )

echo "Master GTID position: $MASTER_GTID"

# Start MariaDB temporarily as 'mysql' user to create replication user
echo "Configuring replication..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -S /var/lib/mysql/mysql.sock <<-EOSQL
-- Configure replication
STOP SLAVE;
SET GLOBAL gtid_slave_pos = '$MASTER_GTID';
CHANGE MASTER TO
  MASTER_HOST='10.1.0.10',
  MASTER_USER='replicator',
  MASTER_PASSWORD='password',
  MASTER_LOG_FILE='$MASTER_LOG_FILE',
  MASTER_LOG_POS=$MASTER_LOG_POS,
  MASTER_USE_GTID=slave_pos,
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