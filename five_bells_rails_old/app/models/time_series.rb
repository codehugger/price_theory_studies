class TimeSeries < ApplicationRecord
  belongs_to :producer, polymorphic: true
end
