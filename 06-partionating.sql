-- Check if partitioning is supported
SELECT * FROM information_schema.plugins WHERE plugin_name = 'partition';

-- Create a partitioned table
ALTER TABLE table1
PARTITION BY RANGE (created_at)*100 + MONTH(created_at) (
    PARTITION p0 VALUES LESS THAN (202301),
    PARTITION p1 VALUES LESS THAN (202302),
    PARTITION p2 VALUES LESS THAN (202303),
    PARTITION pmax VALUES LESS THAN (MAXVALUE)
);

-- show partition information
SELECT
    table_name,
    partition_name,
    partition_ordinal_position,
    partition_description
FROM
    information_schema.partitions
WHERE
    table_name = 'table1';

-- Show partition information
EXPLAIN PARTITIONS SELECT * FROM table1 WHERE created_at = "2024-01-01";

-- Convert partition to table
ALTER TABLE table1 CONVERT PARTITION p0 TO TABLE table1_p0;

-- Convert table to partition
ALTER TABLE table1_p0 CONVERT TO PARTITION p0 VALUES LESS THAN (202301);

-- Drop a partition
ALTER TABLE table1 DROP PARTITION p0; -- also removes the data in the partition

-- Remove partitioning from a table
ALTER TABLE table1 REMOVE PARTITIONING; -- removes partitioning but keeps the data

-- Reorganize partitions
ALTER TABLE table1 REORGANIZE PARTITION p0, p1, p2 INTO (PARTITION p3 VALUES LESS THAN (202304));