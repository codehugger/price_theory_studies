class Ledger < ApplicationRecord
  belongs_to :bank
  has_many :accounts, dependent: :destroy

  after_create :init_accounts
  before_validation :set_ledger_no, on: :create

  def debit(account, amount)
    return false unless accounts.exists?(id: account.id)
    polarized_amount = amount * -1 * self.polarity
    update_deposit(account, polarized_amount)
  end

  def credit(account, amount)
    return false unless accounts.exists?(id: account.id)
    polarized_amount = amount * self.polarity
    update_deposit(account, polarized_amount)
  end

  def account
    raise 'Not a single account ledger' unless single
    raise 'No accounts in ledger' unless accounts.count > 0
    return accounts.first
  end

  def as_json(options=nil)
    {
      name: name,
      ledger_no: ledger_no,
      ledger_type: ledger_type,
      account_type: account_type,
      polarity: polarity,
      single: single
    }
  end

  protected

  def update_deposit(account, amount)
    account.update!(deposit: account.deposit + amount)
    account.update!(inflow: amount) if amount > 0
    account.update!(outflow: amount) if amount < 0
  end

  def init_accounts
    if self.single
      accounts.create(account_no: name, deposit: 0, owner: bank)
    end
  end

  def set_ledger_no
    self.ledger_no = [*('0'..'9')].sample(4).join
  end
end
