-- Show the current value of AUTOCOMMIT
SHOW GLOBAL VARIABLES LIKE 'AUTOCOMMIT';

-- begin a transaction
start transaction;

update emp2 set salary = 750 where id = 1;

commit;

