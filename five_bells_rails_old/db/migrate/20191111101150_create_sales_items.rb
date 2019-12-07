class CreateSalesItems < ActiveRecord::Migration[6.0]
  def change
    create_table :sales_items do |t|
      t.references :sale, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :price

      t.timestamps
    end
  end
end
