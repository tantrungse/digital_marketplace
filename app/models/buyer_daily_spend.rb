class BuyerDailySpend < ApplicationRecord
  self.primary_key = nil

  belongs_to :buyer, class_name: 'User', foreign_key: :buyer_id
  belongs_to :tag, optional: true
  belongs_to :category, optional: true
end
SELECT * FROM
(
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
) subquery
ORDER BY spend_date DESC, buyer_id;