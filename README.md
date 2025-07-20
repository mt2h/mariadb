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