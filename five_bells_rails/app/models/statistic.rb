class Statistic < ApplicationRecord
  belongs_to :world
  has_many :statistic_values

  def record!(value)
    statistic_values.create!(cycle: world.cycle, value: value)
  end
end
