create user 'username'@'host' identified by 'password';
create or replace user 'username'@'host' identified by 'password';

select password('password'); --password_hash
create user 'username'@'host' identified by 'password_hash';

show grants;
show grants for current_user;
show grants for myuser;

-- Grant permissions
grant select on mydatabase.* to 'myuser'@'localhost';
grant select, insert on mydatabase.mytable to 'myuser'@'localhost';
grant execute on procedure mysql.create_db to 'user1'@'host';

revoke select on database1.table1 from 'username'@'localhost';

select current_user();
select User, Host from mysql.user;

FLUSH PRIVILEGES;

-- User and permission management
alter user 'root'@'localhost' identified by '12345678';
create user 'tom'@'localhost' identified by '1234';

-- User and permission management
create database db1;
create table db1.tab1 (txt text);
insert into db1.tab1 values ('hello');
grant select on db1.tab1 to 'tom'@'localhost';
grant create on db1.* to 'tom'@'localhost';
grant update on db1.tab1 to 'tom'@'localhost' with grant option; --delegate same privileges another user
show grants for 'tom'@'localhost';
drop user 'tom'@'localhost';
drop database db1;

-- Create a role
create role role_db1;
create user 'db1_user1'@'localhost' identified by 'password';
grant select, insert on db1.tab1 to role_db1;
grant role_db1 to 'db1_user1'@'localhost';

-- set role
set role role_db1; --as db1_user1 into db
select current_role; --as db1_user1 into db
set default role role_db1; --as db1_user1 into db

set default role role_db1 for 'db1_user1'@'localhost';
set default role none for 'db1_user1'@'localhost';

-- show role grants
show grants for 'db1_user1'@'localhost';
show grants for role_db1;