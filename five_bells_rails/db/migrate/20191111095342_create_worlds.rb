class CreateWorlds < ActiveRecord::Migration[6.0]
  def change
    create_table :worlds do |t|
      t.string :name, null: false
      t.integer :current_cycle, null: false, default: 0
      t.integer :cycle_step_size, null: false, default: 30
      t.boolean :halted, null: false, default: false

      t.timestamps
    end
  end
end
