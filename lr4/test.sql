SET SERVEROUTPUT ON;

COLUMN DEPT_ID FORMAT 9999
COLUMN DEPT_NAME FORMAT A20
SELECT * FROM departments;

CREATE USER c##myuser IDENTIFIED BY mypassword;

GRANT CONNECT, RESOURCE TO c##myuser;
GRANT CREATE TABLE TO c##myuser;
GRANT CREATE TRIGGER TO c##myuser;

--! Allocate quota on the USERS tablespace for the user MYUSER
ALTER USER c##myuser QUOTA UNLIMITED ON USERS;

--------------------------------------------------

-- select e.emp_id, e.emp_name, d.dept_name, e.salary
-- from employees e
-- join departments d
-- on e.dept_id = d.dept_id
-- where e.salary > 1000;

DECLARE
  v_json_input CLOB := '{
    "query_type": "SELECT",
    "select_columns": "e.emp_id, e.emp_name, d.dept_name, e.salary",
    "tables": "employees e, departments d",
    "join_conditions": "e.dept_id = d.dept_id",
    "where_conditions": "e.salary > 1000"
  }';

  v_cursor  SYS_REFCURSOR;
  v_rows    NUMBER;
  v_message VARCHAR2(4000);

  v_emp_id    NUMBER;
  v_emp_name  VARCHAR2(100);
  v_dept_name VARCHAR2(100);
  v_salary    NUMBER;

BEGIN
  dynamic_sql_executor(
    p_json    => v_json_input,
    p_cursor  => v_cursor,
    p_rows    => v_rows,
    p_message => v_message
  );

  DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);

  LOOP
    FETCH v_cursor INTO v_emp_id, v_emp_name, v_dept_name, v_salary;
    EXIT WHEN v_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_emp_id || ', Name: ' || v_emp_name ||
                         ', Dept: ' || v_dept_name || ', Salary: ' || v_salary);
  END LOOP;

  CLOSE v_cursor;
END;
/

--------------------------------------------------

-- select e.emp_id, e.emp_name, d.dept_name, e.salary
-- from employees e
-- join departments d
-- on e.dept_id = d.dept_id
-- where e.salary > 1000
-- and e.emp_id IN (SELECT emp_id FROM employees WHERE salary < 1800);

DECLARE
  v_json_input CLOB := '{
    "query_type": "SELECT",
    "select_columns": "e.emp_id, e.emp_name, d.dept_name, e.salary",
    "tables": "employees e, departments d",
    "join_conditions": "e.dept_id = d.dept_id",
    "where_conditions": "e.salary > 1000",
    "subquery_conditions": "e.emp_id IN (SELECT emp_id FROM employees WHERE salary < 1800)"
  }';

  v_cursor  SYS_REFCURSOR;
  v_rows    NUMBER;
  v_message VARCHAR2(4000);

  v_emp_id    NUMBER;
  v_emp_name  VARCHAR2(100);
  v_dept_name VARCHAR2(100);
  v_salary    NUMBER;

BEGIN
  dynamic_sql_executor(
    p_json    => v_json_input,
    p_cursor  => v_cursor,
    p_rows    => v_rows,
    p_message => v_message
  );

  DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);

  LOOP
    FETCH v_cursor INTO v_emp_id, v_emp_name, v_dept_name, v_salary;
    EXIT WHEN v_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_emp_id || ', Name: ' || v_emp_name ||
                         ', Dept: ' || v_dept_name || ', Salary: ' || v_salary);
  END LOOP;

  CLOSE v_cursor;
END;
/

--------------------------------------------------

-- INSERT INTO employees (emp_id, emp_name, salary, dept_id) VALUES (5, 'Charlie Black', 1300, 10);

DECLARE
  v_json_input CLOB := '{
    "query_type": "INSERT",
    "table": "employees",
    "columns": "emp_id, emp_name, salary, dept_id",
    "values": "5, ''Charlie Black'', 1300, 10"
  }';

  v_cursor  SYS_REFCURSOR;
  v_rows    NUMBER;
  v_message VARCHAR2(4000);

BEGIN
  dynamic_sql_executor(
    p_json    => v_json_input,
    p_cursor  => v_cursor,
    p_rows    => v_rows,
    p_message => v_message
  );

  DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
  DBMS_OUTPUT.PUT_LINE('Affected rows: ' || v_rows);
END;
/

--------------------------------------------------

-- UPDATE employees SET salary = salary * 1.05 WHERE dept_id = 10
-- AND emp_id IN (SELECT emp_id FROM employees WHERE salary < 1500);

DECLARE
  v_json_input CLOB := '{
    "query_type": "UPDATE",
    "table": "employees",
    "set_clause": "salary = salary * 1.05",
    "where_conditions": "dept_id = 10",
    "subquery_conditions": "emp_id IN (SELECT emp_id FROM employees WHERE salary < 1500)"
  }';

  v_cursor  SYS_REFCURSOR;
  v_rows    NUMBER;
  v_message VARCHAR2(4000);

BEGIN
  dynamic_sql_executor(
    p_json    => v_json_input,
    p_cursor  => v_cursor,
    p_rows    => v_rows,
    p_message => v_message
  );

  DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
  DBMS_OUTPUT.PUT_LINE('Affected rows: ' || v_rows);
END;
/

--------------------------------------------------

-- DELETE FROM employees WHERE salary < 1000 AND emp_id IN (SELECT emp_id FROM employees WHERE dept_id = 20);

DECLARE
  v_json_input CLOB := '{
    "query_type": "DELETE",
    "table": "employees",
    "where_conditions": "salary < 1000",
    "subquery_conditions": "emp_id IN (SELECT emp_id FROM employees WHERE dept_id = 20)"
  }';

  v_cursor  SYS_REFCURSOR;
  v_rows    NUMBER;
  v_message VARCHAR2(4000);

BEGIN
  dynamic_sql_executor(
    p_json    => v_json_input,
    p_cursor  => v_cursor,
    p_rows    => v_rows,
    p_message => v_message
  );

  DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
  DBMS_OUTPUT.PUT_LINE('Affected rows: ' || v_rows);
END;
/

--------------------------------------------------

-- CREATE TABLE test_table (
--     id NUMBER,
--     name VARCHAR2(50)
-- );

DECLARE
  v_json_input CLOB := '{
    "query_type": "DDL",
    "ddl_command": "CREATE TABLE",
    "table": "test_table",
    "fields": "id NUMBER, name VARCHAR2(50)"
  }';

  v_cursor  SYS_REFCURSOR;
  v_rows    NUMBER;
  v_message VARCHAR2(4000);

BEGIN
  dynamic_sql_executor(
    p_json    => v_json_input,
    p_cursor  => v_cursor,
    p_rows    => v_rows,
    p_message => v_message
  );

  DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
END;
/

--------------------------------------------------

-- DROP TABLE test_table;

DECLARE
  v_json_input CLOB := '{
    "query_type": "DDL",
    "ddl_command": "DROP TABLE",
    "table": "test_table"
  }';

  v_cursor  SYS_REFCURSOR;
  v_rows    NUMBER;
  v_message VARCHAR2(4000);

BEGIN
  dynamic_sql_executor(
    p_json    => v_json_input,
    p_cursor  => v_cursor,
    p_rows    => v_rows,
    p_message => v_message
  );

  DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
END;
/

--------------------------------------------------

-- CREATE TABLE c##myuser.test_table_with_trigger (
--     id NUMBER PRIMARY KEY,
--     name VARCHAR2(50)
-- );
-- CREATE SEQUENCE c##myuser.test_table_seq START WITH 1 INCREMENT BY 1;
-- CREATE OR REPLACE TRIGGER c##myuser.test_table_trigger
-- BEFORE INSERT ON c##myuser.test_table_with_trigger
-- FOR EACH ROW
-- BEGIN
--     IF :NEW.id IS NULL THEN
--     SELECT c##myuser.test_table_seq.NEXTVAL INTO :NEW.id FROM dual;
--     END IF;
-- END;

DECLARE
  v_json_input CLOB := '{
    "query_type": "DDL",
    "ddl_command": "CREATE TABLE",
    "table": "c##myuser.test_table_with_trigger",
    "fields": "id NUMBER, name VARCHAR2(50)",
    "generate_trigger": "true",
    "trigger_name": "c##myuser.test_table_trigger",
    "pk_field": "id",
    "sequence_name": "c##myuser.test_table_seq"
  }';

  v_cursor  SYS_REFCURSOR;
  v_rows    NUMBER;
  v_message VARCHAR2(4000);

BEGIN
  dynamic_sql_executor(
    p_json    => v_json_input,
    p_cursor  => v_cursor,
    p_rows    => v_rows,
    p_message => v_message
  );

  DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
END;
/

--------------------------------------------------

-- INSERT INTO c##myuser.test_table_with_trigger (name) VALUES ('Test Record');

DECLARE
  v_json_input CLOB := '{
    "query_type": "INSERT",
    "table": "c##myuser.test_table_with_trigger",
    "columns": "name",
    "values": "''Test Record''"
  }';

  v_cursor  SYS_REFCURSOR;
  v_rows    NUMBER;
  v_message VARCHAR2(4000);

BEGIN
  dynamic_sql_executor(
    p_json    => v_json_input,
    p_cursor  => v_cursor,
    p_rows    => v_rows,
    p_message => v_message
  );

  DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
  DBMS_OUTPUT.PUT_LINE('Affected rows: ' || v_rows);
END;
/


--------------------------------------------------

-- SELECT
--     d.dept_id,
--     d.dept_name,
--     SUM(e.salary) AS total_salary,
--     AVG(e.salary) AS avg_salary
-- FROM employees e
-- JOIN departments d ON e.dept_id = d.dept_id
-- WHERE e.salary > 1000
-- GROUP BY d.dept_id, d.dept_name;


DECLARE
  v_json_input CLOB := '{
    "query_type": "SELECT",
    "select_columns": "d.dept_id, d.dept_name, SUM(e.salary) AS total_salary, AVG(e.salary) AS avg_salary",
    "tables": "employees e, departments d",
    "join_conditions": "e.dept_id = d.dept_id",
    "where_conditions": "e.salary > 1000",
    "group_by": "d.dept_id, d.dept_name"
  }';
  v_cursor  SYS_REFCURSOR;
  v_rows    NUMBER;
  v_message VARCHAR2(4000);

  v_dept_id      NUMBER;
  v_dept_name    VARCHAR2(100);
  v_total_salary NUMBER;
  v_avg_salary   NUMBER;
BEGIN
  dynamic_sql_executor(
    p_json    => v_json_input,
    p_cursor  => v_cursor,
    p_rows    => v_rows,
    p_message => v_message
  );

  DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);

  LOOP
    FETCH v_cursor INTO v_dept_id, v_dept_name, v_total_salary, v_avg_salary;
    EXIT WHEN v_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Dept ID: ' || v_dept_id ||
                         ', Dept: ' || v_dept_name ||
                         ', Total Salary: ' || v_total_salary ||
                         ', Avg Salary: ' || v_avg_salary);
  END LOOP;

  CLOSE v_cursor;
END;
/
