-- Не менее двух единиц корма суммарно за 1–15 августа включительно.
-- Исключённый SKU не учитывается в сумме; его покупка не исключает пользователя.
SELECT o.user_id
FROM orders AS o
JOIN order_lines AS l ON l.order_id = o.order_id
JOIN products AS p ON p.product_id = l.product_id
WHERE o.order_date >= '2017-08-01'
  AND o.order_date < '2017-08-16'
  AND LOWER(p.category) = 'продукция для животных'
  AND (LOWER(p.product) LIKE 'корм %' OR LOWER(p.product) LIKE 'паштет %')
  AND LOWER(p.product) <> 'корм kitekat для кошек, с кроликом в соусе, 85 г'
GROUP BY o.user_id
HAVING SUM(l.quantity) >= 2
ORDER BY CAST(o.user_id AS BIGINT);
