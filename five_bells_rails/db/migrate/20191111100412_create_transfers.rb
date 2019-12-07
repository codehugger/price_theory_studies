class CreateTransfers < ActiveRecord::Migration[6.0]
  def change
    create_table :transfers do |t|
      t.references :debit, null: false, foreign_key: { to_table: :accounts }
      t.references :credit, null: false, foreign_key: { to_table: :accounts }
      t.integer :amount
      t.string :description
      t.integer :cycle

      t.timestamps
    end
  end
end
