# mariadb

##  commands

```sql
show variables like 'datadir';
show variables like "innodb_file_per_table";
show variables like "default_storage_engine";
show databases;
```

### documentation

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


## User permission management

```sql
create user 'username'@'host' identified by 'password';
create or replace user 'username'@'host' identified by 'password';

select password('password'); --password_hash
create user 'username'@'host' identified by 'password_hash';

show grants;
show grants for current_user;
show grants for myuser;

grant select on mydatabase.* to 'myuser'@'localhost';
grant select, insert on mydatabase.mytable to 'myuser'@'localhost';
grant execute on procedure mysql.create_db to 'user1'@'host';

revoke select on database1.table1 from 'username'@'localhost';

select current_user();

alter user 'root'@'localhost' identified by '12345678';
create user 'tom'@'localhost' identified by '1234';

create database db1;
create table db1.tab1 (txt text);
insert into db1.tab1 values ('hello');
grant select on db1.tab1 to 'tom'@'localhost';
grant create on db1.* to 'tom'@'localhost';
grant update on db1.tab1 to 'tom'@'localhost' with grant option; --delegate same privileges another user
show grants for 'tom'@'localhost';
drop user 'tom'@'localhost';
drop database db1;
```