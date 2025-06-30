# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_06_26_063617) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "asset_carts", force: :cascade do |t|
    t.integer "cart_id"
    t.integer "asset_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "asset_tags", force: :cascade do |t|
    t.integer "asset_id"
    t.integer "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "assets", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.decimal "price"
    t.string "status"
    t.integer "tag_id"
    t.integer "seller_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "carts", force: :cascade do |t|
    t.integer "buyer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.string "invoice_id"
    t.datetime "order_date"
    t.decimal "total_price"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "purchases", force: :cascade do |t|
    t.decimal "price"
    t.string "download_url"
    t.integer "asset_id"
    t.integer "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.text "content"
    t.integer "asset_id"
    t.integer "buyer_id"
    t.integer "rate_star"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.index ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id"
    t.index ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "parent_tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
    t.index ["category_id"], name: "index_tags_on_category_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", null: false
    t.string "jti", null: false
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "tags", "categories"

  create_view "buyer_daily_spends", materialized: true, sql_definition: <<-SQL
      SELECT date(orders.created_at) AS spend_date,
      orders.user_id AS buyer_id,
      sum(purchases.price) AS total_spent,
      tags.id AS tag_id,
      categories.id AS category_id
     FROM (((((orders
       JOIN purchases ON ((purchases.order_id = orders.id)))
       JOIN assets ON ((purchases.asset_id = assets.id)))
       LEFT JOIN asset_tags ON ((asset_tags.asset_id = assets.id)))
       LEFT JOIN tags ON ((tags.id = asset_tags.tag_id)))
       LEFT JOIN categories ON ((categories.id = tags.category_id)))
    GROUP BY (date(orders.created_at)), orders.user_id, tags.id, categories.id
    ORDER BY (date(orders.created_at)), orders.user_id;
  SQL
  create_view "buyer_weekly_spends", materialized: true, sql_definition: <<-SQL
      SELECT (date_trunc('week'::text, (spend_date)::timestamp with time zone))::date AS week_start,
      buyer_id,
      tag_id,
      category_id,
      sum(total_spent) AS total_spent
     FROM buyer_daily_spends
    GROUP BY (date_trunc('week'::text, (spend_date)::timestamp with time zone)), buyer_id, tag_id, category_id
    ORDER BY ((date_trunc('week'::text, (spend_date)::timestamp with time zone))::date), buyer_id;
  SQL
  create_view "buyer_monthly_spends", materialized: true, sql_definition: <<-SQL
      SELECT (date_trunc('month'::text, (spend_date)::timestamp with time zone))::date AS month,
      buyer_id,
      tag_id,
      category_id,
      sum(total_spent) AS total_spent
     FROM buyer_daily_spends
    GROUP BY (date_trunc('month'::text, (spend_date)::timestamp with time zone)), buyer_id, tag_id, category_id
    ORDER BY ((date_trunc('month'::text, (spend_date)::timestamp with time zone))::date), buyer_id;
  SQL
  create_view "buyer_yearly_spends", materialized: true, sql_definition: <<-SQL
      SELECT (date_trunc('year'::text, (month)::timestamp with time zone))::date AS year_start,
      buyer_id,
      tag_id,
      category_id,
      sum(total_spent) AS total_spent
     FROM buyer_monthly_spends
    GROUP BY (date_trunc('year'::text, (month)::timestamp with time zone)), buyer_id, tag_id, category_id
    ORDER BY ((date_trunc('year'::text, (month)::timestamp with time zone))::date), buyer_id;
  SQL
end
