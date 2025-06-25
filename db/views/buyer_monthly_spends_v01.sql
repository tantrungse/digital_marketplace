SELECT
  DATE_TRUNC('month', spend_date)::date AS month,
  buyer_id,
  tag_id,
  category_id,
  SUM(total_spent) AS total_spent
FROM
  buyer_daily_spends
GROUP BY
  DATE_TRUNC('month', spend_date), buyer_id, tag_id, category_id
ORDER BY
  month, buyer_id;
