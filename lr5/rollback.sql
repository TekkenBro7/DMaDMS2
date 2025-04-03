CREATE OR REPLACE PROCEDURE c##myuser.rollback_by_date(p_target_time IN TIMESTAMP) IS
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE c##myuser.orders DISABLE CONSTRAINT fk_orders_customer';
  EXECUTE IMMEDIATE 'ALTER TABLE c##myuser.order_items DISABLE CONSTRAINT fk_order_items_order';

  EXECUTE IMMEDIATE 'TRUNCATE TABLE c##myuser.order_items';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE c##myuser.orders';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE c##myuser.customers';

  INSERT INTO c##myuser.customers (customer_id, full_name, status_code, created_at)
  SELECT TO_NUMBER(pk_value),
         REGEXP_SUBSTR(changed_data, 'full_name=([^,]+)', 1, 1, NULL, 1),
         TO_NUMBER(REGEXP_SUBSTR(changed_data, 'status_code=([^,]+)', 1, 1, NULL, 1)),
         TO_DATE(REGEXP_SUBSTR(changed_data, 'created_at=([^,]+)', 1, 1, NULL, 1), 'YYYY-MM-DD HH24:MI:SS')
  FROM (
    SELECT a.*, ROW_NUMBER() OVER (PARTITION BY pk_value ORDER BY change_time DESC) rn
    FROM c##myuser.audit_log a
    WHERE table_name = 'CUSTOMERS'
      AND change_time <= p_target_time
  )
  WHERE rn = 1
    AND operation_type <> 'D';

  INSERT INTO c##myuser.orders (order_id, customer_id, order_date, comment_text, amount)
  SELECT TO_NUMBER(pk_value),
         TO_NUMBER(REGEXP_SUBSTR(changed_data, 'customer_id=([^,]+)', 1, 1, NULL, 1)),
         TO_DATE(REGEXP_SUBSTR(changed_data, 'order_date=([^,]+)', 1, 1, NULL, 1), 'YYYY-MM-DD HH24:MI:SS'),
         REGEXP_SUBSTR(changed_data, 'comment_text=([^,]+)', 1, 1, NULL, 1),
         TO_NUMBER(REGEXP_SUBSTR(changed_data, 'amount=([^,]+)', 1, 1, NULL, 1))
  FROM (
    SELECT a.*, ROW_NUMBER() OVER (PARTITION BY pk_value ORDER BY change_time DESC) rn
    FROM c##myuser.audit_log a
    WHERE table_name = 'ORDERS'
      AND change_time <= p_target_time
  )
  WHERE rn = 1
    AND operation_type <> 'D';

  INSERT INTO c##myuser.order_items (order_item_id, order_id, product_name, qty, created_at)
  SELECT TO_NUMBER(pk_value),
         TO_NUMBER(REGEXP_SUBSTR(changed_data, 'order_id=([^,]+)', 1, 1, NULL, 1)),
         REGEXP_SUBSTR(changed_data, 'product_name=([^,]+)', 1, 1, NULL, 1),
         TO_NUMBER(REGEXP_SUBSTR(changed_data, 'qty=([^,]+)', 1, 1, NULL, 1)),
         TO_DATE(REGEXP_SUBSTR(changed_data, 'created_at=([^,]+)', 1, 1, NULL, 1), 'YYYY-MM-DD HH24:MI:SS')
  FROM (
    SELECT a.*, ROW_NUMBER() OVER (PARTITION BY pk_value ORDER BY change_time DESC) rn
    FROM c##myuser.audit_log a
    WHERE table_name = 'ORDER_ITEMS'
      AND change_time <= p_target_time
  )
  WHERE rn = 1
    AND operation_type <> 'D';

  DELETE FROM c##myuser.audit_log WHERE change_time > p_target_time;

  COMMIT;

  EXECUTE IMMEDIATE 'ALTER TABLE c##myuser.orders ENABLE CONSTRAINT fk_orders_customer';
  EXECUTE IMMEDIATE 'ALTER TABLE c##myuser.order_items ENABLE CONSTRAINT fk_order_items_order';
  COMMIT;
END rollback_by_date;
/

CREATE OR REPLACE PACKAGE c##myuser.rollback_pkg IS
  PROCEDURE rollback(p_value IN TIMESTAMP);
  PROCEDURE rollback(p_value IN NUMBER);
END rollback_pkg;
/

CREATE OR REPLACE PACKAGE BODY c##myuser.rollback_pkg AS

  PROCEDURE rollback(p_value IN TIMESTAMP) IS
  BEGIN
    rollback_by_date(p_value);
  END rollback;

  PROCEDURE rollback(p_value IN NUMBER) IS
    v_target TIMESTAMP;
  BEGIN
    v_target := SYSTIMESTAMP - (p_value / (24 * 60 * 60 * 1000));
    rollback_by_date(v_target);
  END rollback;

END rollback_pkg;
/
