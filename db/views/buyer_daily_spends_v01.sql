SELECT
  DATE(orders.created_at) AS spend_date,
  orders.user_id AS buyer_id,
  SUM(purchases.price) AS total_spent
FROM
  orders
JOIN
  purchases ON purchases.order_id = orders.id
GROUP BY
  DATE(orders.created_at), orders.user_id
ORDER BY
  spend_date, buyer_id;
