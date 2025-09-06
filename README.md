# mariadb

## documentation

- Choosing the Right Storage Engine on mariaDB:
https://mariadb.com/kb/en/choosing-the-right-storage-engine/#:~:text=InnoDB%20is%20a%20good%20general,for%20easy%20copying%20between%20systems.


- MariaDB official Docs:
https://mariadb.com/docs/server/


- InnoDB full documentation:
https://mariadb.com/kb/en/innodb/


- InnoDB System Tablespaces documentation:
https://mariadb.com/kb/en/innodb-system-tablespaces/


- InnoDB File-Per-Table Tablespaces documentation:
https://mariadb.com/kb/en/innodb-file-per-table-tablespaces/


- MariaDB with Option Files documentation:
https://mariadb.com/kb/en/configuring-mariadb-with-option-files/


- Binary Log documentation:
https://mariadb.com/kb/en/binary-log/

## Binlog

```bash
mariadb-binlog /var/lib/mysql/mariadb-bin.000001
```

## sysbench

### Install

```bash
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
sudo apt -y install sysbench
```

URL: https://github.com/akopytov/sysbench?tab=readme-ov-file#linux

```sql
create database sbtest;
create user sbtest identified by 'sbtest';
grant all on sbtest.* to 'sbtest'@'%';
```

```bash
sysbench oltp_read_write --threads=2 --mysql-host=127.0.0.1 --mysql-port=3336 --mysql-user=sbtest --mysql-password=sbtest --tables=10 --table-size=100000 prepare

sysbench oltp_read_write --threads=2 --mysql-host=127.0.0.1 --mysql-port=3336 --mysql-user=sbtest --mysql-password=sbtest --tables=10 --table-size=100000 --report-interval=10 --time=20 run
```

## Dump

```bash
# dump all databases
mariadb-dump --host=host --user=user --password=password --all-databases --flush-host --single-transaction --master-data=1 --flush-privileges --quick --triggers --routines --events --hexa-blob > /backup/full_dump.sql
```

## Restore

```bash
# -- install MariaDB with specific user and data directory
mariadb-install-db --user=user --basedir=/usr --data=/data

# restore the database from a full dump
mariadb --host=host --user=user --password=password < /backup/full_dump.sql

head -n 25 /backup/full_dump.sql
#view CHANGE MASTER TO MASTER LOG FILE='mariadb-bin.000018', MASTER_LOG_POS=389

# restore pointing to the binlog files restoring from mariadb-bin.000018 and mariadb-bin.000019
mariadb-binlog --start-position=389 mariadb-bin.000018 mariadb-bin.000019 | mariadb -u root -p
```

## Backup

```bash
mkdir 01_08
# This command creates a physical backup of the MariaDB data.
mariabackup --backup --target-dir=/01_08 --user mariabackup --password 123456

# This command prepares the backup stored in /01_08 by applying redo logs and
# rolling back uncommitted transactions, making the backup ready for restoration
mariabackup --prepare --target-dir=/01_08

# This command copies the prepared backup from /01_08 back to the MariaDB data directory.
# It should be run after the --prepare step and only when the MariaDB server is stopped.
mariabackup --copy-back --target-dir=/01_08
chown -R mysql:mysql /var/lib/mysql

# This command creates an incremental backup based on a previous full backup stored in 01_08/.
# It saves only the data that has changed since the last backup into the /01_09 directory.
mariabackup --backup --target-dir=/01_09 --incremental-basedir=01_08/ --user mariabackup --password 123456
```

## Encripted

```bash
(echo -n "1;" ; openssl rand -hex 32) >> keyfile
```

## Replication

```bash
mariadb -u root -p -S /var/lib/mysql/mysql.sock
```

```sql
SELECT User, Host FROM mysql.user WHERE User='replicator';
SELECT User, Host FROM mysql.user WHERE User='service_user';
show master status;
```

```sql
SHOW REPLICA STATUS\G;
```

### Transform replica to master

```sql
STOP SLAVE;
RESET SLAVE ALL;
```

After activate binary log

```conf
log-bin = /log/binlog/mariadb-bin.log
```