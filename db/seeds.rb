require 'faker'
Rails.application.eager_load!

puts "🚀 Blazing fast seeding started..."

# Clean up dependent tables
Purchase.delete_all
Order.delete_all
AssetTag.delete_all
Asset.delete_all
Tag.delete_all
Category.delete_all

# Optional: clean roles and users if you want
Role.delete_all
User.delete_all

# --- Roles ---
%w[buyer seller].each { |role| Role.find_or_create_by!(name: role) }

# --- Buyers ---
buyers = []
5.times do
  user = User.create!(
    email: Faker::Internet.unique.email,
    password: 'password',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name
  )
  user.roles << Role.find_by(name: 'buyer')
  buyers << user
end

# --- Sellers ---
sellers = []
5.times do
  user = User.create!(
    email: Faker::Internet.unique.email,
    password: 'password',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name
  )
  user.roles << Role.find_by(name: 'seller')
  sellers << user
end

# --- Categories ---
categories = %w[video audio photo].map do |name|
  Category.create!(name: name, description: Faker::Lorem.sentence)
end

# --- Tags and Assets ---
assets = []

categories.each do |category|
  20.times do |i|
    tag = Tag.create!(name: "#{category.name}_tag_#{i+1}", description: Faker::Lorem.sentence, category: category)

    5.times do
      seller = sellers.sample
      asset = Asset.create!(
        seller_id: seller.id,
        title: Faker::Commerce.product_name,
        description: Faker::Lorem.paragraph,
        price: Faker::Commerce.price(range: 5..100),
        status: 'active'
      )
      AssetTag.create!(asset: asset, tag: tag)
      assets << asset
    end
  end
end

puts "✅ Created categories, tags, and #{assets.size} assets."

# 🔥 Blazing-fast mass seeding of Orders and Purchases

total_purchases = 15_000_000
batch_size = 25_000 # we go very big here
purchases_generated = 0
start_date = 5.years.ago
now = Time.now
batch_index = 0

puts "🚀 Seeding #{total_purchases} purchases in batches of #{batch_size}..."

while purchases_generated < total_purchases
  orders_data = []
  purchases_data = []

  # Precompute orders fully in memory
  batch_orders = (batch_size / 3.0).ceil
  order_ids_placeholder = []

  batch_orders.times do
    buyer = buyers.sample
    order_created_at = Faker::Time.between(from: start_date, to: now)
    orders_data << {
      invoice_id: SecureRandom.hex(5),
      order_date: order_created_at,
      total_price: 0,
      user_id: buyer.id,
      created_at: order_created_at,
      updated_at: order_created_at
    }
  end

  inserted_orders = Order.insert_all!(orders_data, returning: %w[id])
  inserted_order_ids = inserted_orders.rows.flatten

  # Precompute purchases fully in memory
  inserted_order_ids.each_with_index do |order_id, index|
    item_count = rand(1..5)
    break if purchases_generated + item_count > total_purchases

    order_date = orders_data[index][:order_date]

    item_count.times do
      asset = assets.sample
      purchases_data << {
        price: asset.price,
        download_url: Faker::Internet.url,
        asset_id: asset.id,
        order_id: order_id,
        created_at: order_date,
        updated_at: order_date
      }
    end

    purchases_generated += item_count
  end

  Purchase.insert_all!(purchases_data)

  batch_index += 1
  puts "✅ Batch #{batch_index}: #{purchases_generated}/#{total_purchases} purchases created"
end

puts "✅ Blazing fast seeding completed!"
