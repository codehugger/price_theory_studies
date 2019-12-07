class CreateGovernments < ActiveRecord::Migration[6.0]
  def change
    create_table :governments do |t|
      t.references :world, null: false, foreign_key: true

      # simulation
      t.references :initial_bank, null: true, foreign_key: { to_table: :banks }
      t.integer :initial_deposit, null: false, default: 0

      t.string :name

      t.string :initial_bank_name

      t.timestamps
    end
  end
end
