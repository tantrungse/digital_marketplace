require 'faker'
Rails.application.eager_load!

puts "Seeding started..."

# --- Delete old data ---
Purchase.delete_all
Order.delete_all
AssetTag.delete_all
Asset.delete_all
Tag.delete_all
Category.delete_all
User.all.each { |u| u.roles.clear } # clean roles for existing users

# (optional cleanup if you want)
# Role.delete_all
# User.delete_all

# === Create Roles ===
roles = %w[buyer seller]
roles.each { |role| Role.find_or_create_by!(name: role) }

# === Create Buyers and Sellers ===
buyers = 5.times.map do
  user = User.create!(
    email: Faker::Internet.unique.email,
    password: 'password',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name
  )
  user.roles << Role.find_by(name: "buyer")
  user
end

sellers = 5.times.map do
  user = User.create!(
    email: Faker::Internet.unique.email,
    password: 'password',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name
  )
  user.roles << Role.find_by(name: "seller")
  user
end

# === Create Categories ===
category_names = %w[video audio photo]
categories = {}
category_names.each do |name|
  categories[name] = Category.create!(
    name: name,
    description: Faker::Lorem.sentence
  )
end

# === Create Tags & Assets ===
assets = []

category_names.each do |category_name|
  category = categories[category_name]

  20.times do |i|
    tag = Tag.create!(
      name: "#{category_name}_tag_#{i + 1}",
      description: Faker::Lorem.sentence,
      category: category
    )

    5.times do
      seller = sellers.sample
      asset = Asset.create!(
        seller_id: seller.id,
        title: Faker::Commerce.product_name,
        description: Faker::Lorem.paragraph,
        price: Faker::Commerce.price(range: 5..100),
        status: 'active'
      )

      AssetTag.create!(asset_id: asset.id, tag_id: tag.id)
      assets << asset
    end
  end
end

puts "Created #{category_names.size} categories, #{category_names.size * 20} tags and #{assets.count} assets"

# === Seed some small test orders first ===
buyers.sample(2).each do |buyer|
  3.times do
    asset = assets.sample
    order = Order.create!(
      invoice_id: SecureRandom.hex(5),
      order_date: Faker::Date.between(from: 3.years.ago, to: Date.today),
      total_price: asset.price,
      user: buyer
    )
    Purchase.create!(
      price: asset.price,
      download_url: Faker::Internet.url,
      asset: asset,
      order: order
    )
  end
end

puts "Initial test orders created"

# === Massive Order + Purchase generation ===

puts "Seeding 15 million purchases..."

total_purchases = 15_000_000
batch_size = 10_000
purchases_generated = 0
start_date = 5.years.ago
now = Time.now
batch_index = 0

while purchases_generated < total_purchases
  orders_data = []
  order_items_data = []

  # Estimate orders count for this batch
  approx_orders_count = (batch_size / 3.0).ceil

  # Create orders
  approx_orders_count.times do
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

  # Bulk insert orders
  inserted_orders = Order.insert_all!(orders_data).rows.flatten

  inserted_orders.each do |order_id|
    item_count = rand(1..5)
    break if purchases_generated + item_count > total_purchases

    # All purchases for this order get same created_at as order
    order_created_at = orders_data.find { |o| o[:user_id] == Order.find(order_id).user_id }[:created_at]

    item_count.times do
      asset = assets.sample
      order_items_data << {
        price: asset.price,
        download_url: Faker::Internet.url,
        asset_id: asset.id,
        order_id: order_id,
        created_at: order_created_at,
        updated_at: order_created_at
      }
    end

    purchases_generated += item_count
  end

  Purchase.insert_all!(order_items_data)

  batch_index += 1
  puts "Batch #{batch_index} completed: #{purchases_generated}/#{total_purchases} purchases created"
end

puts "✅ Seeding completed!"
