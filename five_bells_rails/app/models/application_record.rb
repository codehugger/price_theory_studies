class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def generate_number_sequence(length)
    [*('0'..'9')].sample(length).join
  end

  def self.union(scope1, scope2)
    ids = scope1.pluck(:id) + scope2.pluck(:id)
    where(id: ids.uniq)
  end
end
