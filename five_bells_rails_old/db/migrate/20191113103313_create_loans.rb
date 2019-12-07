class CreateLoans < ActiveRecord::Migration[6.0]
  def change
    create_table :loans do |t|
      t.references :owner_account, null: false, foreign_key: { to_table: :accounts }
      t.references :borrower_account, null: false, foreign_key: { to_table: :accounts }
      t.string :loan_no, null: false
      t.integer :principal, null: false, default: 0
      t.float :interest_rate, null: false, default: 0.0
      t.integer :duration, null: false, default: 1
      t.integer :frequency, null: false, default: 1
      t.string :loan_type, null: false, default: "compound"

      t.timestamps
    end
  end
end
