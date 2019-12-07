module Trackable
  include ActiveSupport::Concern

  def track(cycle, label, value)
    Statistics.create!(cycle: cycle, label: label, value: value, provider: self)
  end
end
