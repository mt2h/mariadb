show variables like 'performance_schema%';

USE performance_schema;

-- show the most time-consuming queries
-- This query retrieves the top queries by total execution time
SELECT DIGEST_TEXT AS query, COUNT_STAR AS executions,
SUM_TIMER_WAIT / 1000000000000 AS total_time_sec
FROM performance_schema.events_statements_summary_by_digest
ORDER BY total_time_sec DESC;

-- Shows file I/O events with the highest total wait time in milliseconds
SELECT EVENT_NAME, COUNT_READ, COUNT_WRITE, SUM_TIMER_WAIT /
1000000000 AS total_wait_ms
FROM performance_schema.file_summary_by_event_name ORDER BY
total_wait_ms DESC;

-- Summary of table lock waits: counts and total wait time (ms) per table, ordered by highest wait time
SELECT OBJECT_SCHEMA, OBJECT_NAME, COUNT_STAR AS lock_count,
SUM_TIMER_WAIT / 1000000000 AS total_lock_time_ms
FROM performance_schema.table_lock_waits_summary_by_table
ORDER BY total_lock_time_ms DESC;

-- Count of index usage per table and index, ordered by least used indexes
SELECT OBJECT_SCHEMA, OBJECT_NAME, INDEX_NAME, COUNT_FETCH
AS index_usage_count
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE INDEX_NAME IS NOT NULL
ORDER BY index_usage_count ASC;

-- Lists active threads excluding idle ones,
-- showing user, command, state, and duration
SELECT THREAD_ID, PROCESSLIST_USER, PROCESSLIST_COMMAND,
PROCESSLIST_STATE, PROCESSLIST_TIME AS time_sec
FROM performance_schema.threads
WHERE PROCESSLIST_COMMAND != 'Sleep'
ORDER BY time_sec DESC

-- Counts active connections per user and host,
-- showing which users and hosts have the most connections.
SELECT PROCESSLIST_USER, PROCESSLIST_HOST, COUNT(*) AS
connection_count
FROM performance_schema.threads
WHERE PROCESSLIST_USER IS NOT NULL
GROUP BY PROCESSLIST_USER, PROCESSLIST_HOST
ORDER BY connection_count DESC;