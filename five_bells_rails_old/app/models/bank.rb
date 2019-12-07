class Bank < Company
  ACCOUNT_POLARITIES = {"ASSET" => -1, "LIABILITY" => +1, "EQUITY" => +1}

  has_many :ledgers, dependent: :destroy
  has_many :accounts, through: :ledgers

  before_validation :set_bank_no, on: :create

  after_create :init_ledgers

  def capital_ledger() ledgers.find_by(name: "capital") end
  def cash_ledger() ledgers.find_by(name: "cash") end
  def deposit_ledger() ledgers.find_by(name: "deposit") end
  def ib_debt_ledger() ledgers.find_by(name: "ib_debt") end
  def interest_income_ledger() ledgers.find_by(name: "interest_income") end
  def loan_ledger() ledgers.find_by(name: "loan") end
  def loss_provision_ledger() ledgers.find_by(name: "loss_provision") end
  def loss_reserve_ledger() ledgers.find_by(name: "loss_reserve") end
  def non_cash_ledger() ledgers.find_by(name: "non_cash") end
  def reserve_ledger() ledgers.find_by(name: "reserve") end
  def retained_earnings_ledger() ledgers.find_by(name: "retained_earnings") end

  #############################################################################
  # Account Management
  #############################################################################

  def open_deposit_account(owner=nil) deposit_ledger.accounts.create!(owner: owner) unless owner.nil? || owner == self end

  def transfer(sender, receiver, amount, description)
    if sender.bank != self
      # # incoming money
      reserve_ledger.debit("reserve", amount)
      reserve_ledger.credit(receiver, amount)
    elsif receiver.bank != self
      # outoing money
      deposit_ledger.debit(sender, amount)
      reserve_ledger.credit("reserve", amount)

      # notify other bank
      receiver.bank.transfer(sender, receiver, amount, description)
    else
      # internal transfer
      sender.ledger.debit(sender, amount)
      receiver.ledger.credit(receiver, amount)
    end

    record_transfer(sender, receiver, amount, description)
  end


  #############################################################################
  # Loans
  #############################################################################

  def request_loan(borrower_account, amount, duration, frequency=1, loan_type="COMPOUND")
    customer_loan = Loan.create!(borrower_account: borrower_account,
                                 owner_account: loan_ledger.account,
                                 principal: amount,
                                 interest_rate: current_compound_interest_rate,
                                 duration: duration,
                                 frequency: frequency,
                                 loan_type: loan_type)

    if customer_loan.persisted?
      # debit ASSET, credit: LIABILITY
      transfer(loan_ledger.account, borrower_account, customer_loan.principal, "Loan #{customer_loan.loan_no}")
    end
  end

  def loan_capital_outstanding
    loan_ledger.account.loans.collect(&:principal_remaining).sum
  end

  def debt_capital_outstanding
    interbank.account.loans.collect(&:principal_remaining).sum
  end

  #############################################################################
  # JSON
  #############################################################################

  def as_json(options=nil)
    { name: name, bank_no: bank_no }
  end

  def self.from_json(json)
    new(name: hash["name"], initial_capital: 0, initial_cash: 0)
  end

  protected

  def init_ledgers
  end

  # TODO: make this use a proper interest rate matrix
  def current_compound_interest_rate() 4.3 end

  def record_transfer(sender, receiver, amount, description)
    Transfer.create!(sender: sender, receiver: receiver, amount: amount, description: description)
  end

  def set_bank_no
    self.bank_no = [*('0'..'9')].sample(4).join
  end
end
