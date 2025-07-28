show variables like '%innodb%';

set global innodb_adaptive_flushing=OFF;

show status like 'threads_connected';

-- Show current connections
show full processlist;
select user, count(*) as connection from information_schema.processlist group by user;

-- Show thread cache size
show variables like 'thread_cache_size';