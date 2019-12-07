class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.references :ledger, null: false, foreign_key: true
      t.references :owner, polymorphic: true, null: false
      t.string :account_no, null: false
      t.integer :deposit, null: false, default: 0
      t.integer :inflow, null: false, default: 0
      t.integer :outflow, null: false, default: 0

      t.timestamps
    end
  end
end
