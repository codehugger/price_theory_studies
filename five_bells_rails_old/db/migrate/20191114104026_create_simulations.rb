class CreateSimulations < ActiveRecord::Migration[6.0]
  def change
    create_table :simulations do |t|
      t.string :version
      t.json :world_data
      t.integer :cycles
      t.string :status

      t.timestamps
    end
  end
end
