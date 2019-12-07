class CreateStatistics < ActiveRecord::Migration[6.0]
  def change
    create_table :statistics do |t|
      t.references :world, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
