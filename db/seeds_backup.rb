require 'faker'
Rails.application.eager_load!
 
puts "Seeding started..."
 
# --- Delete old data ---
OrderItem.delete_all
Order.delete_all
Product.delete_all
AssetTag.delete_all
Tag.delete_all
Category.delete_all
UserRole.delete_all
Role.delete_all
User.delete_all
 
# === Create Roles ===
roles = %w[buyer seller]
roles.each { |role| Role.create!(name: role) }
 
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
category_names = %w[image video audio]
categories = {}
category_names.each do |name|
  categories[name] = Category.create!(
    name: name,
    description: Faker::Lorem.sentence
  )
end
 
# === Create Tags & Assets for each Category ===
products = []
 
category_names.each do |category_name|
  category = categories[category_name]
 
  20.times do |i|
    tag = Tag.create!(
      name: "#{category_name}_tag_#{i + 1}",
      description: Faker::Lorem.sentence
    )
 
    5.times do
      seller = sellers.sample
      product = Product.create!(
        seller_id: seller.id,
        title: Faker::Commerce.product_name,
        description: Faker::Lorem.paragraph,
        price: Faker::Commerce.price(range: 5..100),
        category_id: category.id,
        published: true
      )
 
      # Assign tag to product
      AssetTag.create!(asset_id: product.id, tag_id: tag.id)
      products << product
    end
  end
end
 
puts "Created #{category_names.size} categories, #{category_names.size * 20} tags and #{products.count} assets"
 
# === Seed some small test orders ===
buyers.sample(2).each do |buyer|
  3.times do
    product = products.sample
    order = Order.create!(
      invoice_id: SecureRandom.hex(5),
      order_date: Faker::Date.between(from: 3.years.ago, to: Date.today),
      total_price: product.price,
      user_id: buyer.id
    )
    OrderItem.create!(
      price: product.price,
      download_url: Faker::Internet.url,
      asset_id: product.id,
      order_id: order.id
    )
  end
end
 
puts "Initial test orders created"
 
puts "Seeding 15 million OrderItems..."
 
total_order_items = 15_000_000
batch_size_items = 10_000
order_items_generated = 0
start_date = 5.years.ago.to_date
days_range = (0..(5 * 365))
now = Time.now
 
batch_index = 0
 
while order_items_generated < total_order_items
  orders_data = []
  order_items_data = []
 
  # Estimate number of orders to create based on 1–5 items per order
  approx_orders_count = (batch_size_items / 3.0).ceil
 
  approx_orders_count.times do
    buyer = buyers.sample
    order = {
      invoice_id: SecureRandom.hex(5),
      order_date: start_date + rand(days_range),
      total_price: 0,
      user_id: buyer.id,
      created_at: now,
      updated_at: now
    }
    orders_data << order
  end
 
  inserted_orders = Order.insert_all!(orders_data).rows.flatten
 
  inserted_orders.each do |order_id|
    item_count = rand(1..5)
    break if order_items_generated + item_count > total_order_items
 
    item_count.times do
      product = products.sample
      order_items_data << {
        price: product.price,
        download_url: Faker::Internet.url,
        asset_id: product.id,
        order_id: order_id,
        created_at: now,
        updated_at: now
      }
    end
 
    order_items_generated += item_count
  end
 
  OrderItem.insert_all!(order_items_data)
 
  batch_index += 1
  puts "Batch #{batch_index} completed: #{order_items_generated}/#{total_order_items} OrderItems created"
end
 
puts "OrderItem seeding completed."
puts "All seed data has been created successfully."