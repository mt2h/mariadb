create database abc;
use abc;
create table tab1(id int, name varchar(50));
insert into tab1 values (1, 'James');

create user 'mariabackup'@'localhost' identified by '123456';
grant reload, process, lock tables, binlog monitor on *.* to 'mariabackup'@'localhost';

-- show binlog current position
show master status;