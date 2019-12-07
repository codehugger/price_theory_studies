class CreateBanks < ActiveRecord::Migration[6.0]
  def change
    create_table :banks do |t|
      t.references :world, null: false, foreign_key: true

      t.string :name, null: false
      t.string :bank_no, null: false

      # allow central bank inheritance
      t.string :type

      # shares
      t.integer :share_price, null: false, default: 0

      # capital
      t.integer :min_capital, null: false, default: 50
      t.float :capital_pct, null: false, default: 0.2
      t.integer :capital_steps, null: false, default: 12

      # loans
      t.float :interest_reate_delta, null: false, default: 0
      t.integer :write_off_limit, null: false, default: 6
      t.float :loss_provision_pct, null: false, default: 0.01

      t.integer :labour_output, null: false, default: 0

      t.timestamps
    end
  end
end
