-- PostgreSQL. Ключи ID имеют тип text, order_date имеет тип date.
-- Первый наблюдаемый заказ за всю доступную историю, до фильтра города/дат.
-- При одинаковой дате выбирается меньший числовой order_id.
-- Частота = число первых заказов с товаром, а не сумма quantity.
WITH ranked_orders AS (
    SELECT o.*,
           ROW_NUMBER() OVER (
               PARTITION BY o.user_id
               ORDER BY o.order_date, CAST(o.order_id AS BIGINT)
           ) AS order_rank
    FROM orders AS o
), selected_orders AS (
    SELECT o.order_id
    FROM ranked_orders AS o
    JOIN warehouses AS w ON w.warehouse_id = o.warehouse_id
    WHERE o.order_rank = 1
      AND o.order_date >= '2017-08-15'
      AND o.order_date <  '2017-08-31'
      AND w.city = 'Санкт-Петербург'
), frequency AS (
    SELECT l.product_id, COUNT(DISTINCT l.order_id) AS first_order_count
    FROM selected_orders AS o
    JOIN order_lines AS l ON l.order_id = o.order_id
    GROUP BY l.product_id
)
SELECT f.product_id,
       COALESCE(p.product, 'Нет в справочнике') AS product,
       f.first_order_count
FROM frequency AS f
LEFT JOIN products AS p ON p.product_id = f.product_id
ORDER BY f.first_order_count DESC, f.product_id ASC
LIMIT 5;
