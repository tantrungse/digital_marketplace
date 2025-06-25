SELECT
  DATE_TRUNC('week', spend_date)::date AS week_start,
  buyer_id,
  tag_id,
  category_id,
  SUM(total_spent) AS total_spent
FROM
  buyer_daily_spends
GROUP BY
  DATE_TRUNC('week', spend_date), buyer_id, tag_id, category_id
ORDER BY
  week_start, buyer_id;
