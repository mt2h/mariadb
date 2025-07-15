show variables like '%innodb%';

set global innodb_adaptive_flushing=OFF;

show status like 'threads_connected';

show full processlist;
select user, count(*) as connection from information_schema.processlist group by user;

show variables like 'thread_cache_size';