class GovernmentBank < ApplicationRecord
  belongs_to :government
  belongs_to :bank
end
