class CreatePeople < ActiveRecord::Migration[6.0]
  def change
    create_table :people do |t|
      t.references :region, null: false, foreign_key: true
      t.references :employer, null: true, polymorphic: true

      # personal info
      t.string :name
      t.integer :age, null: false, default: -1

      # finances
      t.references :initial_bank, null: true, foreign_key: { to_table: :banks }
      t.integer :initial_deposit, null: false, default: 0

      # salary related
      t.integer :salary, null: false, default: 0
      t.integer :desired_salary, null: false, default: 1

      # allow inherited people
      t.string :type, null: false, default: 'Person'

      t.timestamps
    end
  end
end
