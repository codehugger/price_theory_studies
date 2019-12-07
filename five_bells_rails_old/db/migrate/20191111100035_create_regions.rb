class CreateRegions < ActiveRecord::Migration[6.0]
  def change
    create_table :regions do |t|
      t.references :world, null: true, foreign_key: true

      t.string :name, null: false
      t.string :ancestry, index: true

      t.timestamps
    end
  end
end
