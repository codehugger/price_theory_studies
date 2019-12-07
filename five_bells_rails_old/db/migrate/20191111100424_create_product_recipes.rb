class CreateProductRecipes < ActiveRecord::Migration[6.0]
  def change
    create_table :product_recipes do |t|
      t.string :product_name
      t.string :ancestry, index: true

      t.timestamps
    end
  end
end
