class AddBorrowerFieldsToPeople < ActiveRecord::Migration[6.0]
  def change
    add_column :people, :loan_amount, :integer, null: false, default: -1
    add_column :people, :loan_type, :string, null: false, default: "COMPOUND"
    add_column :people, :loan_duration, :integer, null: false, default: -1
    add_column :people, :borrower_window, :integer, null: false, default: 1
    add_column :people, :bank_employee, :boolean, null: false, default: false
    add_reference :people, :bank, null: true, foreign_key: true
    add_reference :people, :loan, null: true, foreign_key: true
  end
end
