class CreateStatisticValues < ActiveRecord::Migration[6.0]
  def change
    create_table :statistic_values do |t|
      t.references :statistic, null: false, foreign_key: true
      t.integer :cycle, null: false
      t.float :value, null: false
    end
  end
end
