class CreateTimeSeries < ActiveRecord::Migration[6.0]
  def change
    create_table :time_series do |t|
      t.references :provider, null: false, polymorphic: true
      t.integer :cycle, null: false
      t.string :label, null: false
      t.integer :value, null: false

      t.timestamps
    end
  end
end
