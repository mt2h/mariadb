show global variables like 'plugin_dir';

install soname 'server_audit'

show global variables like 'server_audit%';

-- show indexes on table of database
SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME, NON_UNIQUE FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'mysql' AND TABLE_NAME = 'server_audit';

-- show privileges of users
SELECT * FROM information_schema.USER_PRIVILEGES;

-- show tables in database empty
SELECT TABLE_NAME, TABLE_ROWS FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'mysql' AND TABLE_ROWS = 0;

-- show columns in table
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, COLUMN_TYPE FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'mysql' AND TABLE_NAME = 'server_audit';
