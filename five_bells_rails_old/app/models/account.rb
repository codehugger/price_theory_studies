class Account < ApplicationRecord
  belongs_to :ledger
  belongs_to :owner, polymorphic: true

  has_many :loans, foreign_key: 'owner_account_id', class_name: 'Loan'
  has_many :debts, foreign_key: 'borrower_account_id', class_name: 'Loan'

  has_many :outoing_transfers, foreign_key: 'source_id', class_name: 'Transfer'
  has_many :incoming_transfers, foreign_key: 'receiver_id', class_name: 'Transfer'

  delegate :bank, to: :ledger

  validates :deposit, numericality: { :only_integer => true, :greater_than_or_equal_to => 0 }

  before_validation :set_account_no, on: :create

  def transfer_to(account, amount, description)
    bank.transfer(self, account, amount, description)
  end

  def deposit_cash(amount)
    bank.deposit_cash(self, amount)
  end

  def netto_flow
    self.inflow - self.outflow
  end

  def absolute_account_no
    "#{bank.bank_no}-#{ledger.ledger_no}-#{account_no}"
  end

  def debt_outstanding
    debts.collect(&:principal_remaining).sum
  end

  def request_loan(amount, duration, frequency=1, loan_type="COMPOUND")
    bank.request_loan(self, amount, duration, frequency, loan_type)
  end

  protected

  def set_account_no()
    self.account_no ||= generate_number_sequence(6)
  end
end
