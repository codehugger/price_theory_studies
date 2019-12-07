class CreateSales < ActiveRecord::Migration[6.0]
  def change
    create_table :sales do |t|
      t.references :buyer, null: false, polymorphic: true
      t.references :seller, null: false, polymorphic: true
      t.references :transfer, null: false, foreign_key: true
      t.integer :cycle

      t.timestamps
    end
  end
end
