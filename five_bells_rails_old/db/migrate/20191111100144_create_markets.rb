class CreateMarkets < ActiveRecord::Migration[6.0]
  def change
    create_table :markets do |t|
      t.references :world, null: true, foreign_key: true
      t.references :region, null: false, foreign_key: true
      t.string :name

      # finances
      t.references :initial_bank, null: true, foreign_key: { to_table: :banks }
      t.integer :initial_deposit, null: false, default: 0
      t.integer :cash_buffer, null: false, default: 4

      # product
      t.string :product_name, null: false
      t.integer :max_inventory, null: false, default: 20

      # employees
      t.integer :max_employees, null: false, default: 1
      t.integer :salaries_paid, null: false, default: 0

      # prices
      t.integer :last_sold_price, null: false, default: -1
      t.integer :bid_price, null: false, default: 1
      t.integer :sell_price, null: false, default: 2
      t.boolean :bid_equals_ask, null: false, default: false

      # spread
      t.integer :min_spread, null: false, default: 1
      t.integer :max_spread, null: false, default: 5
      t.integer :spread, null: false, default: 1

      # inventory rules
      t.boolean :attempt_to_buy, null: false, default: false

      # profit margin
      t.float :profit_margin, null: false, default: 0.1

      t.timestamps
    end
  end
end
