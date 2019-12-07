class CreateLedgers < ActiveRecord::Migration[6.0]
  def change
    create_table :ledgers do |t|
      t.references :bank, null: false, foreign_key: true
      t.string :name, null: false
      t.string :ledger_no, null: false
      t.string :ledger_type, null: false
      t.string :account_type, null: false
      t.integer :polarity, null: false, default: 1
      t.boolean :single, null: false, default: false

      t.timestamps
    end
  end
end
