DROP TABLE MyTable;

-- 1. Создание таблицы
CREATE TABLE MyTable (
    id NUMBER PRIMARY KEY,
    val NUMBER
);

-- 2. Анонимный блок для вставки 10 000 случайных записей
DECLARE
    v_id NUMBER;
    v_val NUMBER;
BEGIN
    FOR i IN 1..100 LOOP
        v_id := i;
        v_val := TRUNC(DBMS_RANDOM.VALUE(1, 100));
        INSERT INTO MyTable (id, val) VALUES (v_id, v_val);
    END LOOP;
    COMMIT;
END;
/

SELECT * FROM MyTable;

-- 3. Функция для подсчёта четных и нечетных значений val
CREATE OR REPLACE FUNCTION CheckEvenOdd RETURN VARCHAR2 IS
    even_count NUMBER := 0;
    odd_count NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO even_count FROM MyTable WHERE MOD(val, 2) = 0;
    SELECT COUNT(*) INTO odd_count FROM MyTable WHERE MOD(val, 2) = 1;
    
    IF even_count > odd_count THEN
        RETURN 'TRUE';
    ELSIF even_count < odd_count THEN
        RETURN 'FALSE';
    ELSE
        RETURN 'EQUAL';
    END IF;
END;
/

SELECT * FROM MyTable;

SELECT CheckEvenOdd FROM dual;

-- SELECT 1+1 FROM DUAL;
-- SELECT SYSDATE FROM dual;

-- 4. Функция генерации команды INSERT по ID
CREATE OR REPLACE FUNCTION generate_insert_command(p_id IN NUMBER) RETURN VARCHAR2 IS
    v_val NUMBER;
    v_command VARCHAR2(100);
    v_max_id NUMBER;
BEGIN
    SELECT MAX(id) INTO v_max_id FROM MyTable;
    
    IF p_id < 0 OR p_id > v_max_id THEN
        RAISE_APPLICATION_ERROR(-20001, 'ID MUST BE NON-NEGATIVE AND LESS THAN OR EQUAL TO MAX ID');
    END IF;

    SELECT val INTO v_val FROM MyTable WHERE id = p_id;
    v_command := 'INSERT INTO MyTable (id, val) VALUES (' || p_id || ', ' || v_val || ');';
    RETURN v_command;
END;
/

SELECT generate_insert_command(-1) FROM dual; 


-- 5. Процедуры для DML операций
-- INSERT
CREATE OR REPLACE PROCEDURE InsertIntoMyTable(p_id NUMBER, p_val NUMBER) IS
BEGIN
    INSERT INTO MyTable (id, val) VALUES (p_id, p_val);
    COMMIT;
EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20003, 'Запись с таким ID уже существует');
END;
/

BEGIN
    InsertIntoMyTable(101, 12);
END;
/

SELECT * FROM MyTable;

-- UPDATE
CREATE OR REPLACE PROCEDURE UpdateMyTable(p_id NUMBER, p_val NUMBER) IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM MyTable WHERE id = p_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Запись с указанным ID не найдена');
    END IF;
    
    UPDATE MyTable SET val = p_val WHERE id = p_id;
    COMMIT;
END;
/

BEGIN
    UpdateMyTable(101, 14);
END;
/

SELECT * FROM MyTable;

-- DELETE
CREATE OR REPLACE PROCEDURE DeleteFromMyTable(p_id NUMBER) IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM MyTable WHERE id = p_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Запись с указанным ID не найдена');
    END IF;
    
    DELETE FROM MyTable WHERE id = p_id;
    COMMIT;
END;
/

BEGIN
    DeleteFromMyTable(99);
END;
/

SELECT * FROM MyTable;


-- 6. Функция расчёта годового вознаграждения
CREATE OR REPLACE FUNCTION calculate_total_reward(monthly_salary NUMBER, bonus_percent NUMBER) RETURN NUMBER IS
    v_bonus_ratio NUMBER;
    v_annual_reward NUMBER;
BEGIN
    IF monthly_salary <= 0 OR bonus_percent < 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Некорректные данные!');
    END IF;
    
    IF NOT REGEXP_LIKE(bonus_percent, '^\d+$') THEN
        RAISE_APPLICATION_ERROR(-20005, 'Ввод должен быть целым числом!');
    END IF;

    v_bonus_ratio := bonus_percent / 100;
    v_annual_reward := (1 + v_bonus_ratio) * 12 * monthly_salary;
    
    RETURN v_annual_reward;
END;
/
SELECT calculate_total_reward(130, 50) FROM dual;