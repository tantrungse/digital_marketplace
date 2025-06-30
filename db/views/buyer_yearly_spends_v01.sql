SELECT
  DATE_TRUNC('year', month)::date AS year_start,
  buyer_id,
  tag_id,
  category_id,
  SUM(total_spent) AS total_spent
FROM
  buyer_monthly_spends
GROUP BY
  DATE_TRUNC('year', month), buyer_id, tag_id, category_id
ORDER BY
  year_start, buyer_id;
