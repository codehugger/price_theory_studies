# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_18_221050) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "ledger_id", null: false
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.string "account_no", null: false
    t.integer "deposit", default: 0, null: false
    t.integer "inflow", default: 0, null: false
    t.integer "outflow", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ledger_id"], name: "index_accounts_on_ledger_id"
    t.index ["owner_type", "owner_id"], name: "index_accounts_on_owner_type_and_owner_id"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "banks", force: :cascade do |t|
    t.bigint "world_id", null: false
    t.string "name", null: false
    t.string "bank_no", null: false
    t.string "type"
    t.integer "share_price", default: 0, null: false
    t.integer "min_capital", default: 50, null: false
    t.float "capital_pct", default: 0.2, null: false
    t.integer "capital_steps", default: 12, null: false
    t.float "interest_reate_delta", default: 0.0, null: false
    t.integer "write_off_limit", default: 6, null: false
    t.float "loss_provision_pct", default: 0.01, null: false
    t.integer "labour_output", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["world_id"], name: "index_banks_on_world_id"
  end

  create_table "factories", force: :cascade do |t|
    t.bigint "world_id", null: false
    t.string "name"
    t.bigint "initial_bank_id"
    t.integer "initial_deposit", default: 0, null: false
    t.integer "min_capital", default: 50, null: false
    t.integer "offered_salary", default: 1, null: false
    t.integer "asking_price", default: 10, null: false
    t.integer "last_sold_price", default: -1, null: false
    t.integer "labour_output", default: 1, null: false
    t.string "product_name", null: false
    t.integer "max_inventory", default: 20, null: false
    t.boolean "allow_direct_purchase", default: false, null: false
    t.float "component_margin", default: 0.5, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["initial_bank_id"], name: "index_factories_on_initial_bank_id"
    t.index ["world_id"], name: "index_factories_on_world_id"
  end

  create_table "government_banks", force: :cascade do |t|
    t.bigint "government_id", null: false
    t.bigint "bank_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bank_id"], name: "index_government_banks_on_bank_id"
    t.index ["government_id"], name: "index_government_banks_on_government_id"
  end

  create_table "governments", force: :cascade do |t|
    t.bigint "world_id", null: false
    t.bigint "initial_bank_id"
    t.integer "initial_deposit", default: 0, null: false
    t.string "name"
    t.string "initial_bank_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["initial_bank_id"], name: "index_governments_on_initial_bank_id"
    t.index ["world_id"], name: "index_governments_on_world_id"
  end

  create_table "ledgers", force: :cascade do |t|
    t.bigint "bank_id", null: false
    t.string "name", null: false
    t.string "ledger_no", null: false
    t.string "ledger_type", null: false
    t.string "account_type", null: false
    t.integer "polarity", default: 1, null: false
    t.boolean "single", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bank_id"], name: "index_ledgers_on_bank_id"
  end

  create_table "loan_payments", force: :cascade do |t|
    t.bigint "loan_id", null: false
    t.bigint "interest_transfer_id"
    t.bigint "capital_transfer_id"
    t.string "payment_no", default: "0", null: false
    t.integer "capital"
    t.integer "interest"
    t.boolean "scheduled", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["capital_transfer_id"], name: "index_loan_payments_on_capital_transfer_id"
    t.index ["interest_transfer_id"], name: "index_loan_payments_on_interest_transfer_id"
    t.index ["loan_id"], name: "index_loan_payments_on_loan_id"
  end

  create_table "loans", force: :cascade do |t|
    t.bigint "owner_account_id", null: false
    t.bigint "borrower_account_id", null: false
    t.string "loan_no", null: false
    t.integer "principal", default: 0, null: false
    t.float "interest_rate", default: 0.0, null: false
    t.integer "duration", default: 1, null: false
    t.integer "frequency", default: 1, null: false
    t.string "loan_type", default: "compound", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["borrower_account_id"], name: "index_loans_on_borrower_account_id"
    t.index ["owner_account_id"], name: "index_loans_on_owner_account_id"
  end

  create_table "markets", force: :cascade do |t|
    t.bigint "world_id"
    t.string "name"
    t.bigint "initial_bank_id"
    t.integer "initial_deposit", default: 0, null: false
    t.integer "cash_buffer", default: 4, null: false
    t.string "product_name", null: false
    t.integer "max_inventory", default: 20, null: false
    t.integer "max_employees", default: 1, null: false
    t.integer "salaries_paid", default: 0, null: false
    t.integer "offered_salary", default: 1, null: false
    t.integer "last_sold_price", default: -1, null: false
    t.integer "bid_price", default: 1, null: false
    t.integer "sell_price", default: 2, null: false
    t.boolean "bid_equals_ask", default: false, null: false
    t.integer "min_spread", default: 1, null: false
    t.integer "max_spread", default: 5, null: false
    t.integer "spread", default: 1, null: false
    t.boolean "attempt_to_buy", default: false, null: false
    t.float "profit_margin", default: 0.1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["initial_bank_id"], name: "index_markets_on_initial_bank_id"
    t.index ["world_id"], name: "index_markets_on_world_id"
  end

  create_table "people", force: :cascade do |t|
    t.bigint "world_id", null: false
    t.string "employer_type"
    t.bigint "employer_id"
    t.string "name"
    t.integer "age", default: -1, null: false
    t.bigint "initial_bank_id"
    t.integer "initial_deposit", default: 0, null: false
    t.integer "salary", default: 0, null: false
    t.integer "desired_salary", default: 1, null: false
    t.string "type", default: "Person", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "loan_amount", default: -1, null: false
    t.string "loan_type", default: "COMPOUND", null: false
    t.integer "loan_duration", default: -1, null: false
    t.integer "borrower_window", default: 1, null: false
    t.boolean "bank_employee", default: false, null: false
    t.bigint "bank_id"
    t.bigint "loan_id"
    t.index ["bank_id"], name: "index_people_on_bank_id"
    t.index ["employer_type", "employer_id"], name: "index_people_on_employer_type_and_employer_id"
    t.index ["initial_bank_id"], name: "index_people_on_initial_bank_id"
    t.index ["loan_id"], name: "index_people_on_loan_id"
    t.index ["world_id"], name: "index_people_on_world_id"
  end

  create_table "product_recipes", force: :cascade do |t|
    t.string "product_name"
    t.string "ancestry"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ancestry"], name: "index_product_recipes_on_ancestry"
  end

  create_table "products", force: :cascade do |t|
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.string "producer_type", null: false
    t.bigint "producer_id", null: false
    t.bigint "product_recipe_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["owner_type", "owner_id"], name: "index_products_on_owner_type_and_owner_id"
    t.index ["producer_type", "producer_id"], name: "index_products_on_producer_type_and_producer_id"
    t.index ["product_recipe_id"], name: "index_products_on_product_recipe_id"
  end

  create_table "sales", force: :cascade do |t|
    t.string "buyer_type", null: false
    t.bigint "buyer_id", null: false
    t.string "seller_type", null: false
    t.bigint "seller_id", null: false
    t.bigint "transfer_id", null: false
    t.integer "cycle"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["buyer_type", "buyer_id"], name: "index_sales_on_buyer_type_and_buyer_id"
    t.index ["seller_type", "seller_id"], name: "index_sales_on_seller_type_and_seller_id"
    t.index ["transfer_id"], name: "index_sales_on_transfer_id"
  end

  create_table "sales_items", force: :cascade do |t|
    t.bigint "sale_id", null: false
    t.bigint "product_id", null: false
    t.integer "price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_sales_items_on_product_id"
    t.index ["sale_id"], name: "index_sales_items_on_sale_id"
  end

  create_table "statistic_values", force: :cascade do |t|
    t.bigint "statistic_id", null: false
    t.integer "cycle", null: false
    t.float "value", null: false
    t.index ["statistic_id"], name: "index_statistic_values_on_statistic_id"
  end

  create_table "statistics", force: :cascade do |t|
    t.bigint "world_id", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["world_id"], name: "index_statistics_on_world_id"
  end

  create_table "transfers", force: :cascade do |t|
    t.bigint "debit_id", null: false
    t.bigint "credit_id", null: false
    t.integer "amount"
    t.string "description"
    t.integer "cycle"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["credit_id"], name: "index_transfers_on_credit_id"
    t.index ["debit_id"], name: "index_transfers_on_debit_id"
  end

  create_table "worlds", force: :cascade do |t|
    t.string "name", null: false
    t.integer "current_cycle", default: 0, null: false
    t.integer "cycle_step_size", default: 30, null: false
    t.boolean "halted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "accounts", "ledgers"
  add_foreign_key "banks", "worlds"
  add_foreign_key "factories", "banks", column: "initial_bank_id"
  add_foreign_key "factories", "worlds"
  add_foreign_key "government_banks", "banks"
  add_foreign_key "government_banks", "governments"
  add_foreign_key "governments", "banks", column: "initial_bank_id"
  add_foreign_key "governments", "worlds"
  add_foreign_key "ledgers", "banks"
  add_foreign_key "loan_payments", "loans"
  add_foreign_key "loan_payments", "transfers", column: "capital_transfer_id"
  add_foreign_key "loan_payments", "transfers", column: "interest_transfer_id"
  add_foreign_key "loans", "accounts", column: "borrower_account_id"
  add_foreign_key "loans", "accounts", column: "owner_account_id"
  add_foreign_key "markets", "banks", column: "initial_bank_id"
  add_foreign_key "markets", "worlds"
  add_foreign_key "people", "banks"
  add_foreign_key "people", "banks", column: "initial_bank_id"
  add_foreign_key "people", "loans"
  add_foreign_key "people", "worlds"
  add_foreign_key "products", "product_recipes"
  add_foreign_key "sales", "transfers"
  add_foreign_key "sales_items", "products"
  add_foreign_key "sales_items", "sales"
  add_foreign_key "statistic_values", "statistics"
  add_foreign_key "statistics", "worlds"
  add_foreign_key "transfers", "accounts", column: "credit_id"
  add_foreign_key "transfers", "accounts", column: "debit_id"
end
