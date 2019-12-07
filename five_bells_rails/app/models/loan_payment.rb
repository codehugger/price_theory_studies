class LoanPayment < ApplicationRecord
  belongs_to :loan
  belongs_to :capital_transfer, optional: true, foreign_key: 'interest_transfer_id', class_name: 'Transfer'
  belongs_to :interest_transfer, optional: true, foreign_key: 'capital_transfer_id', class_name: 'Transfer'

  scope :scheduled,     -> { where(scheduled: true) }
  scope :unscheduled,   -> { where(scheduled: false) }
  scope :paid,          -> { where.not(capital_transfer: nil) }
  scope :remaining,     -> { where(scheduled: true, capital_transfer: nil, interest_transfer: nil) }
  scope :capital_paid,  -> { where(scheduled: true, capital_transfer: nil) }
  scope :interest_paid, -> { where(scheduled: true, interest_transfer: nil) }

  # scheduled amounts
  def total() capital + interest end

  # payments
  def capital_paid() capital_transfer.try(:amount) end
  def interest_paid() capital_transfer.try(:amount) end
  def total_paid() capital_paid + interest_paid end
  def paid?() total - total_paid == 0 end
end
