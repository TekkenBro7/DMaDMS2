INSERT INTO c##myuser.customers (full_name, status_code) VALUES ('Alice', 10);
INSERT INTO c##myuser.customers (full_name, status_code) VALUES ('Bob', 2);
COMMIT;

INSERT INTO
    c##myuser.customers (full_name, status_code)
VALUES ('Alex', 5);

INSERT INTO c##myuser.orders (customer_id, comment_text, amount)
VALUES (1, 'Заказ от Alice', 150);
INSERT INTO c##myuser.orders (customer_id, comment_text, amount)
VALUES (2, 'Заказ от Bob', 250);
COMMIT;

INSERT INTO c##myuser.order_items (order_id, product_name, qty)
VALUES (1, 'Товар A', 2);
INSERT INTO c##myuser.order_items (order_id, product_name, qty)
VALUES (1, 'Товар B', 5);
COMMIT;

UPDATE c##myuser.customers
   SET full_name = 'Alice Updated'
 WHERE customer_id = 1;

INSERT INTO c##myuser.orders (customer_id, comment_text, amount)
VALUES (1, 'Дополнительный заказ', 300);

DELETE FROM c##myuser.order_items
 WHERE order_item_id = 1;

COMMIT;

SELECT * FROM c##myuser.customers;
SELECT * FROM c##myuser.orders;
SELECT * FROM c##myuser.order_items;

BEGIN
  c##myuser.rollback_pkg.rollback(TIMESTAMP '2025-04-02 15:00:00');
END;
/


BEGIN
  c##myuser.rollback_pkg.rollback(100000);
END;
/

COMMIT;


BEGIN
  c##myuser.report_pkg.create_report(TIMESTAMP '2025-04-02 15:14:00');
END;
/


BEGIN
  c##myuser.report_pkg.create_report();
END;
/
