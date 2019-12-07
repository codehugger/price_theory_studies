class Transfer < ApplicationRecord
  belongs_to :debit, foreign_key: 'debit_id', class_name: 'Account'
  belongs_to :credit, foreign_key: 'credit_id', class_name: 'Account'

  delegate :bank, to: :debit

  def debit_no() debit.account_no end
  def credit_no() credit.account_no end
end
