class Loan < ApplicationRecord
  LOAN_TYPES = ["SIMPLE", "COMPOUND", "INTERBANK", "VARIABLE"]

  belongs_to :borrower_account, foreign_key: 'borrower_account_id', class_name: 'Account'
  belongs_to :owner_account, foreign_key: 'owner_account_id', class_name: 'Account'

  has_many :loan_payments, dependent: :destroy

  has_many :capital_transfers, through: :loan_payments
  has_many :interest_transfers, through: :loan_payments

  def transfers() capital_transfers + interest_transfers end

  validates :loan_type, inclusion: { in: LOAN_TYPES }
  validates :principal, numericality: { :only_integer => true, :greater_than_or_equal_to => 0 }
  validate :forbid_changes, on: :update

  after_create :create_loan_payments
  after_update :reset_payments!
  before_validation :set_loan_no

  delegate :bank, to: :owner_account
  delegate :ledger, to: :owner_account

  alias_method :payments, :loan_payments

  def owner() owner_account.try(:owner) end
  def borrower() borrower_account.try(:owner) end

  def monthly_rate() interest_rate * 0.01 / 12.0 end
  def no_payments() duration / frequency end
  def paid?() principal_remaining == 0 && interest_remaining == 0 end
  def interest_total() payments.scheduled.sum(:interest) end

  def capital_paid() payments.paid.collect(&:capital).sum end
  def total_paid() capital_paid + interest_paid end
  def interest_paid() payments.paid.collect(&:interest).sum end

  def principal_remaining() principal - capital_paid end
  def interest_remaining() interest_total - interest_paid end

  def next_payment() payments.remaining.first end
  def make_payment() bank.make_loan_payment(self.next_payment) end

  def payment_due?(cycle=nil)
    return !next_payment.nil? if cycle.nil?
    cycle % frequency == 0 && principal_remaining > 0
  end

  def monthly_payment()
    case loan_type.upcase
    when "COMPOUND", "INTERBANK", "VARIABLE"
      # montly payment c
      #  c = P*r / (1 - (1/(1+r)**n))
      # where
      #   * P: principal
      #   * r = monthly interest rate
      #   * n = number of payment periods (months)
      #   * c = monthly payment
      (principal * monthly_rate) / (1.0 - (1.0 / (1.0 + monthly_rate) ** duration))
    else
      (principal.to_f / no_payments)
    end
  end

  def reset_payments!
    payments.destroy_all
    create_loan_payments
  end

  def as_json(options=nil)
    { loan_no: loan_no }
  end

  protected

  def add_baloon_payment(payments)
    # Make last capital payment a baloon payment to compensate for rounding errors
    payments.last[:capital] += (principal_remaining - payments.reduce(0){|sum,x| sum + x[:capital]})
    payments
  end

  def calculate_payments_for_simple_loan(current_remains)
    interest_payment = (monthly_payment * monthly_rate).round
    (1..no_payments).map do |payment_no|
      { payment_no: payment_no,
        capital: monthly_payment,
        interest: interest_payment,
        scheduled: true,
        loan: self }
    end
  end

  def calculate_payments_for_compound_loan(current_remains)
    (1..no_payments).map do |payment_no|
      interest_payment = current_remains * monthly_rate
      capital_payment = (monthly_payment - interest_payment).round
      current_remains -= capital_payment

      { payment_no: payment_no,
        capital: capital_payment,
        interest: interest_payment.round,
        scheduled: true,
        loan: self }
    end
  end

  protected

  def set_loan_no()
    self.loan_no ||= generate_number_sequence(6)
  end

  def create_loan_payments
    raise 'Remaining principal is zero' if principal_remaining == 0

    # delete any unpaid scheduled payments
    loan_payments.destroy_all

    # here we copy the calculated principal remaining for performance reasons
    results = case loan_type.upcase
      when "COMPOUND", "INTERBANK", "VARIABLE"
        calculate_payments_for_compound_loan(principal)
      else
        calculate_payments_for_simple_loan(principal)
    end

    # Make sure the rounding error is compensated for
    results = add_baloon_payment(results)

    LoanPayment.create(results)
  end

  def forbid_changes
    errors.add(:base, 'Loans with payments made cannot be changed.') if total_paid > 0
  end
end
