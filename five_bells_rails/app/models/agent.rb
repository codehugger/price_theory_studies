class Agent < ApplicationRecord
  self.abstract_class = true

  belongs_to :world
  has_many :employees, as: :employer, foreign_key: "employer_id", class_name: "Person"

  delegate :cycle, to: :world
  delegate :statistics, to: :world

  before_validation :set_name

  after_create :init_statistics

  def record_stats_and_reset_internals
    record_stats
    reset_internals
  end

  def record_stats
  end

  def reset_internals
  end

  protected

  def init_statistics
  end

  def evaluate
    raise NotImplementedError, self.class.name
  end
end
