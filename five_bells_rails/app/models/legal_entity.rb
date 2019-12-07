class LegalEntity < Agent
  self.abstract_class = true

  belongs_to :initial_bank, optional: true, foreign_key: 'initial_bank_id', class_name: 'CustomerBank'
  has_one :account, as: :owner

  delegate :customer_banks, to: :world
  delegate :account_no, to: :account
  delegate :absolute_account_no, to: :account
  delegate :bank, to: :account

  after_create :open_deposit_account

  protected

  def open_deposit_account
    bank = initial_bank.nil? ? customer_banks.shuffle.first : initial_bank
    self.account = bank.open_deposit_account(self)
    account.bank.deposit_cash(self.account, initial_deposit, "Initial deposit") if initial_deposit > 0
  end
end
