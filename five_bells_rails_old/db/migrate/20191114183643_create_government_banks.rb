class CreateGovernmentBanks < ActiveRecord::Migration[6.0]
  def change
    create_table :government_banks do |t|
      t.references :government, null: false, foreign_key: true
      t.references :bank, null: false, foreign_key: true

      t.timestamps
    end
  end
end
