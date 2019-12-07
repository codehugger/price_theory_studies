class Agent < ApplicationRecord
  self.abstract_class = true
  include Evaluated

  before_validation :set_name

  has_many :employees, as: :employer, foreign_key: "employer_id", class_name: "Person"
end
