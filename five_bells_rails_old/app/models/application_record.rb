class ApplicationRecord < ActiveRecord::Base
  include Trackable
  self.abstract_class = true

  def generate_number_sequence(length)
    [*('0'..'9')].sample(length).join
  end
end
