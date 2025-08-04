show variables like 'datadir';
show variables like "innodb_file_per_table";
show variables like "default_storage_engine";

show databases;


mariadb-binlog --start-position=389 --disable-binlog mariadb-bin.000018 mariadb-bin.000019