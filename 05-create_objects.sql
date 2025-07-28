-- copy structure of an existing table
create table company.emp2 like company.emp;

-- The MEMORY engine (formerly known as HEAP) stores all table data in RAM. This has significant advantages and limitations
create table memory_emp (id int, name varchar(50)) engine=memory;
alter table memory_emp add index idx_mem_emp (name) using hash;


DELIMITER //

CREATE PROCEDURE company.GetFamilyName(IN input_id INT)
BEGIN
  DECLARE family_name VARCHAR(255);

  /* Extract the family name from 'Name' column */
  SELECT SUBSTRING_INDEX(name, ' ', -1)
  INTO family_name
  FROM emp2
  WHERE id = input_id;

  /* Output the family name */
  SELECT family_name AS FamilyName;
END //

DELIMITER ;

CALL company.GetFamilyName(1);

DELIMITER //

CREATE FUNCTION company.reFamilyName(input_id INT)
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
  DECLARE family_name VARCHAR(255);

  /* Extract the family name from 'Name' column */
  SELECT SUBSTRING_INDEX(name, ' ', -1)
  INTO family_name
  FROM emp2
  WHERE id = input_id;

  /* Return the family name */
  RETURN family_name;
END //

DELIMITER ;

-- Call the function to get the family name
SELECT company.reFamilyName(1);

-- Event Scheduler: Create an event to clean up old logs
CREATE EVENT cleanup_event
ON SCHEDULE EVERY 1 DAY
DO DELETE FROM logs WHERE log_date < NOW() - INTERVAL 30 DAY;


-- Create a trigger to enforce a business rule on salary changes
DELIMITER //

CREATE TRIGGER tr_salary_emp2
BEFORE UPDATE ON emp2
FOR EACH ROW
BEGIN
  DECLARE salary_change DECIMAL(10,2);
  SET salary_change = (NEW.salary - OLD.salary) / OLD.salary * 100;
  IF salary_change > 10 OR salary_change < -10 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Error: salary change exceeds 10% limit.';
  END IF;
END //

DELIMITER ;

-- Create a view to simplify access to employee information
CREATE VIEW ev_emp2_info AS SELECT name, birthday FROM emp2;
SELECT * FROM ev_emp2_info;