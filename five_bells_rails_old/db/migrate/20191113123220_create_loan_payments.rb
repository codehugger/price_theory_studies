class CreateLoanPayments < ActiveRecord::Migration[6.0]
  def change
    create_table :loan_payments do |t|
      t.references :loan, null: false, foreign_key: true
      t.references :interest_transfer, null: true, foreign_key: { to_table: :transfers }
      t.references :capital_transfer, null: true, foreign_key: { to_table: :transfers }
      t.string :payment_no, null: false, default: 0
      t.integer :capital
      t.integer :interest
      t.boolean :scheduled, null: false, default: false

      t.timestamps
    end
  end
end
