SELECT
  DATE(orders.created_at) AS spend_date,
  orders.user_id AS buyer_id,
  SUM(purchases.price) AS total_spent,
  tags.id AS tag_id,
  categories.id AS category_id
FROM
  orders
JOIN
  purchases ON purchases.order_id = orders.id
JOIN
  assets ON purchases.asset_id = assets.id
LEFT JOIN
  asset_tags ON asset_tags.asset_id = assets.id
LEFT JOIN
  tags ON tags.id = asset_tags.tag_id
LEFT JOIN
  categories ON categories.id = tags.category_id
GROUP BY
  DATE(orders.created_at), orders.user_id, tags.id, categories.id
ORDER BY
  spend_date, buyer_id;
