class CentralBank < Bank
  after_create :init_ledgers

  def init_ledgers
    ledgers.create(name: "interest_income", account_type: "LIABILITY", ledger_type: "DEPOSIT", polarity: ACCOUNT_POLARITIES["LIABILITY"], single: true)
    ledgers.create(name: "loan", account_type: "ASSET", ledger_type: "LOAN", polarity: ACCOUNT_POLARITIES["ASSET"], single: true)
    ledgers.create(name: "non_cash", account_type: "LIABILITY", ledger_type: "DEPOSIT", polarity: ACCOUNT_POLARITIES["LIABILITY"], single: true)
    ledgers.create(name: "reserve", account_type: "ASSET", ledger_type: "DEPOSIT", polarity: ACCOUNT_POLARITIES["ASSET"], single: true)
  end

  protected

  def set_name
    self.name = "CentralBank"
  end
end
