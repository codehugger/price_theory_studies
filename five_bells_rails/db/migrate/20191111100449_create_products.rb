class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.references :owner, null: false, polymorphic: true
      t.references :producer, null: false, polymorphic: true
      t.references :product_recipe, null: false, foreign_key: true

      t.timestamps
    end
  end
end
