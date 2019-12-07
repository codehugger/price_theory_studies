class CreateFactories < ActiveRecord::Migration[6.0]
  def change
    create_table :factories do |t|
      t.references :region, null: false, foreign_key: true

      t.string :name

      # finances
      t.references :initial_bank, null: true, foreign_key: { to_table: :banks }
      t.integer :initial_deposit, null: false, default: 0
      t.integer :min_capital, null: false, default: 50

      # employees
      t.integer :offered_salary, null: false, default: 1

      # prices
      t.integer :asking_price, null: false, default: 10
      t.integer :last_sold_price, null: false, default: -1

      # productivity
      t.integer :labour_output, null: false, default: 1

      # product
      t.string :product_name, null: false
      t.integer :max_inventory, null: false, default: 20

      # keiretsu-style direct purchase
      t.boolean :allow_direct_purchase, null: false, default: false
      t.float :component_margin, null: false, default: 0.5

      t.timestamps
    end
  end
end
