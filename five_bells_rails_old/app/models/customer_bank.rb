class CustomerBank < Bank

  #############################################################################
  # Transfers
  #############################################################################

  def deposit_cash(account, amount, description = "Cash deposit")
    return false if account.bank != self
    # debit ASSET, credit LIABILITY
    transfer(cash_ledger.account, account, amount, description)
  end

  def deposit_capital(amount, description = "Capital deposit")
    # debit ASSET, credit LIABILITY
    transfer(cash_ledger.account, capital.account, amount, description)
  end

  def make_loan_payment(payment)
    return false if payment.nil?

    # transfer capital amount if there is any
    if payment.capital > 0
      # debit borrower account credit loan
      capital_transfer = transfer(payment.loan.borrower_account, loan_ledger.account, payment.capital, "Capital payment #{payment.payment_no}")
      payment.update!(capital_transfer: capital_transfer)
    end

    # transfer interest amount if there is any
    if payment.interest > 0
      interest_transfer = transfer(payment.loan.borrower_account, interest_income_ledger.account, payment.interest, "Interest payment #{payment.payment_no}")
      payment.update!(interest_transfer: interest_transfer)
    end
  end

  #############################################################################
  # Simulation
  #############################################################################

  def evaluate(cycle)
    pay_salaries(cycle)
    pay_debts(cycle)
    pay_interbank_loans(cycle)
    apply_loss_prevision(cycle)
    handle_reserves(cycle)
  end

  def pay_salaries(cycle)
    employees.each do |x| transfer(interest_income_ledger.account, x.account, x.salary, "Salary payment - #{cycle}") end
  end

  def pay_debts(cycle)
  end

  def pay_interbank_loans(cycle)
  end

  def apply_loss_prevision(cycle)
  end

  def handle_reserves(cycle)
  end

  protected

  def set_name
    self.name ||= "CustomerBank - #{generate_number_sequence(6)}"
  end

  def init_ledgers
    ledgers.create(name: "capital", account_type: "EQUITY", ledger_type: "CAPITAL", polarity: ACCOUNT_POLARITIES["EQUITY"], single: true)
    ledgers.create(name: "cash", account_type: "ASSET", ledger_type: "CASH", polarity: ACCOUNT_POLARITIES["ASSET"], single: true)
    ledgers.create(name: "deposit", account_type: "LIABILITY", ledger_type: "DEPOSIT", polarity: ACCOUNT_POLARITIES["LIABILITY"], single: false)
    ledgers.create(name: "ib_debt", account_type: "LIABILITY", ledger_type: "LOAN", polarity: ACCOUNT_POLARITIES["LIABILITY"], single: true)
    ledgers.create(name: "interest_income", account_type: "LIABILITY", ledger_type: "DEPOSIT", polarity: ACCOUNT_POLARITIES["LIABILITY"], single: true)
    ledgers.create(name: "loan", account_type: "ASSET", ledger_type: "LOAN", polarity: ACCOUNT_POLARITIES["ASSET"], single: true)
    ledgers.create(name: "loss_provision", account_type: "LIABILITY", ledger_type: "DEPOSIT", polarity: ACCOUNT_POLARITIES["LIABILITY"], single: true)
    ledgers.create(name: "loss_reserve", account_type: "ASSET", ledger_type: "DEPOSIT", polarity: ACCOUNT_POLARITIES["ASSET"], single: true)
    ledgers.create(name: "non_cash", account_type: "LIABILITY", ledger_type: "DEPOSIT", polarity: ACCOUNT_POLARITIES["LIABILITY"], single: true)
    ledgers.create(name: "reserve", account_type: "ASSET", ledger_type: "DEPOSIT", polarity: ACCOUNT_POLARITIES["ASSET"], single: true)
    ledgers.create(name: "retained_earnings", account_type: "EQUITY", ledger_type: "DEPOSIT", polarity: ACCOUNT_POLARITIES["EQUITY"], single: true)
  end
end
