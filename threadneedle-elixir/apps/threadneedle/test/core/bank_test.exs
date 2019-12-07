defmodule BankTest do
  use ExUnit.Case

  alias Threadneedle.Core.{Account, Bank, GeneralLedger, Ledger, Loan}

  # doctest Threadneedle.Core.Bank

  test "initializing with new should create default ledgers and accounts" do
    bank = Bank.new(bank_no: "bank01")

    assert bank.bank_no == "bank01"

    assert bank.general_ledger.ledgers["capital"] == %Ledger{
             name: "capital",
             ledger_type: "capital",
             account_type: "equity",
             accounts: %{"capital" => %Account{account_no: "capital"}}
           }

    assert bank.general_ledger.ledgers["cash"] == %Ledger{
             name: "cash",
             ledger_type: "cash",
             account_type: "asset",
             accounts: %{"cash" => %Account{account_no: "cash"}}
           }

    assert bank.general_ledger.ledgers["deposit"] == %Ledger{
             name: "deposit",
             ledger_type: "deposit",
             account_type: "liability",
             accounts: %{}
           }

    assert bank.general_ledger.ledgers["ib_debt"] == %Ledger{
             name: "ib_debt",
             ledger_type: "loan",
             account_type: "liability",
             accounts: %{"ib_debt" => %Account{account_no: "ib_debt"}}
           }

    assert bank.general_ledger.ledgers["interest_income"] == %Ledger{
             name: "interest_income",
             ledger_type: "deposit",
             account_type: "liability",
             accounts: %{"interest_income" => %Account{account_no: "interest_income"}}
           }

    assert bank.general_ledger.ledgers["loan"] == %Ledger{
             name: "loan",
             ledger_type: "loan",
             account_type: "asset",
             accounts: %{"loan" => %Account{account_no: "loan"}}
           }

    assert bank.general_ledger.ledgers["loss_provision"] == %Ledger{
             name: "loss_provision",
             ledger_type: "deposit",
             account_type: "liability",
             accounts: %{"loss_provision" => %Account{account_no: "loss_provision"}}
           }

    assert bank.general_ledger.ledgers["loss_reserve"] == %Ledger{
             name: "loss_reserve",
             ledger_type: "deposit",
             account_type: "asset",
             accounts: %{"loss_reserve" => %Account{account_no: "loss_reserve"}}
           }

    assert bank.general_ledger.ledgers["non_cash"] == %Ledger{
             name: "non_cash",
             ledger_type: "deposit",
             account_type: "liability",
             accounts: %{"non_cash" => %Account{account_no: "non_cash"}}
           }

    assert bank.general_ledger.ledgers["reserve"] == %Ledger{
             name: "reserve",
             ledger_type: "deposit",
             account_type: "asset",
             accounts: %{"reserve" => %Account{account_no: "reserve"}}
           }

    assert bank.general_ledger.ledgers["retained_earnings"] == %Ledger{
             name: "retained_earnings",
             ledger_type: "deposit",
             account_type: "equity",
             accounts: %{"retained_earnings" => %Account{account_no: "retained_earnings"}}
           }
  end

  test "transfer between known accounts in the same ledger should update deposits" do
    {:ok, bank} =
      Bank.transfer(
        %Bank{
          bank_no: "bank01",
          general_ledger: %GeneralLedger{
            ledgers: %{
              "deposit" => %Ledger{
                name: "ledger01",
                ledger_type: "deposit",
                account_type: "liability",
                accounts: %{
                  "acc01" => %Account{account_no: "acc01", deposit: 100},
                  "acc02" => %Account{account_no: "acc02", deposit: 0}
                }
              }
            }
          }
        },
        "acc01",
        "acc02",
        60,
        "... just because"
      )

    assert bank.general_ledger.ledgers["ledger01"].accounts["acc01"].deposit == 40
    assert bank.general_ledger.ledgers["ledger01"].accounts["acc02"].deposit == 60
  end

  test "transfer between known accounts in different ledgers should update deposits" do
    {:ok, bank} =
      Bank.transfer(
        %Bank{
          bank_no: "bank01",
          general_ledger: %GeneralLedger{
            ledgers: %{
              "ledger01" => %Ledger{
                name: "ledger01",
                ledger_type: "deposit",
                account_type: "liability",
                accounts: %{
                  "acc01" => %Account{account_no: "acc01", deposit: 100}
                }
              },
              "ledger02" => %Ledger{
                name: "ledger02",
                ledger_type: "deposit",
                account_type: "liability",
                accounts: %{
                  "acc02" => %Account{account_no: "acc02", deposit: 0}
                }
              }
            }
          }
        },
        "acc01",
        "acc02",
        60,
        "... just because"
      )

    assert bank.general_ledger.ledgers["ledger01"].accounts["acc01"].deposit == 40
    assert bank.general_ledger.ledgers["ledger02"].accounts["acc02"].deposit == 60
  end

  test "transfer from known to unknown accounts should update deposit and reserve" do
    {:ok, bank} =
      Bank.transfer(
        %Bank{
          bank_no: "bank01",
          general_ledger: %GeneralLedger{
            ledgers: %{
              "ledger01" => %Ledger{
                name: "ledger01",
                ledger_type: "deposit",
                account_type: "liability",
                accounts: %{
                  "acc01" => %Account{account_no: "acc01", deposit: 100}
                }
              },
              "reserve" => %Ledger{
                name: "reserve",
                ledger_type: "deposit",
                account_type: "asset",
                accounts: %{
                  "reserve" => %Account{account_no: "reserve", deposit: 100}
                }
              }
            }
          }
        },
        "acc01",
        "acc02",
        60,
        "... just because"
      )

    assert bank.general_ledger.ledgers["ledger01"].accounts["acc01"].deposit == 40
    assert bank.general_ledger.ledgers["reserve"].accounts["reserve"].deposit == 40
  end

  test "transfer from unknown and known accounts should update deposit and reserve" do
    {:ok, bank} =
      Bank.transfer(
        %Bank{
          bank_no: "bank01",
          general_ledger: %GeneralLedger{
            ledgers: %{
              "ledger01" => %Ledger{
                name: "ledger01",
                ledger_type: "deposit",
                account_type: "liability",
                accounts: %{
                  "acc01" => %Account{account_no: "acc01", deposit: 0}
                }
              },
              "reserve" => %Ledger{
                name: "reserve",
                ledger_type: "deposit",
                account_type: "asset",
                accounts: %{
                  "reserve" => %Account{account_no: "reserve", deposit: 0}
                }
              }
            }
          }
        },
        "acc02",
        "acc01",
        60,
        "... just because"
      )

    assert bank.general_ledger.ledgers["ledger01"].accounts["acc01"].deposit == 60
    assert bank.general_ledger.ledgers["reserve"].accounts["reserve"].deposit == 60
  end

  test "loan request without risk profile should result in loan updates" do
    {:ok, bank} =
      Bank.request_loan(
        %Bank{
          bank_no: "bank01",
          general_ledger: %GeneralLedger{
            ledgers: %{
              "deposit" => %Ledger{
                name: "deposit",
                ledger_type: "deposit",
                account_type: "liability",
                accounts: %{
                  "acc01" => %Account{account_no: "acc01", deposit: 0}
                }
              },
              "loan" => %Ledger{
                name: "loan",
                ledger_type: "loan",
                account_type: "asset",
                accounts: %{
                  "loan" => %Account{account_no: "loan", deposit: 0}
                }
              }
            }
          }
        },
        100,
        12,
        0,
        "acc01"
      )

    [loan_no] = bank.loan_book.accounts["acc01"]

    {:ok, loan} =
      Loan.new(%{
        loan_no: loan_no,
        capital: 100,
        interest_rate: 0.0,
        loan_type: "compound",
        duration: 12,
        owner_account_no: "loan"
      })

    assert Bank.get_loan(bank, loan_no) == loan

    assert bank.general_ledger.ledgers["deposit"].accounts["acc01"].deposit == 100
    assert bank.general_ledger.ledgers["loan"].accounts["loan"].deposit == 100
  end

  test "scheduled loan payments are booked correctly" do
    {:ok, bank} =
      Bank.request_loan(
        %Bank{
          bank_no: "bank01",
          general_ledger: %GeneralLedger{
            ledgers: %{
              "deposit" => %Ledger{
                name: "deposit",
                ledger_type: "deposit",
                account_type: "liability",
                accounts: %{
                  "acc01" => %Account{account_no: "acc01", deposit: 0}
                }
              },
              "loan" => %Ledger{
                name: "loan",
                ledger_type: "loan",
                account_type: "asset",
                accounts: %{
                  "loan" => %Account{account_no: "loan", deposit: 0}
                }
              },
              "interest_income" => %Ledger{
                name: "interest_income",
                ledger_type: "deposit",
                account_type: "liability",
                accounts: %{
                  "interest_income" => %Account{account_no: "interest_income", deposit: 0}
                }
              }
            }
          }
        },
        120,
        12,
        0.1,
        "acc01"
      )

    [loan_no] = bank.loan_book.accounts["acc01"]

    bank = bank |> Bank.make_loan_payment(loan_no, "acc01")

    assert Bank.get_account(bank, "loan").deposit == 110
    assert Bank.get_account(bank, "interest_income").deposit == 1.0
    assert Bank.get_account(bank, "acc01").deposit == 109
  end

  test "unscheduled loan payments are booked correctly" do
    {:ok, bank} =
      Bank.request_loan(
        %Bank{
          bank_no: "bank01",
          general_ledger: %GeneralLedger{
            ledgers: %{
              "deposit" => %Ledger{
                name: "deposit",
                ledger_type: "deposit",
                account_type: "liability",
                accounts: %{
                  "acc01" => %Account{account_no: "acc01", deposit: 0}
                }
              },
              "loan" => %Ledger{
                name: "loan",
                ledger_type: "loan",
                account_type: "asset",
                accounts: %{
                  "loan" => %Account{account_no: "loan", deposit: 0}
                }
              },
              "interest_income" => %Ledger{
                name: "interest_income",
                ledger_type: "deposit",
                account_type: "liability",
                accounts: %{
                  "interest_income" => %Account{account_no: "interest_income", deposit: 0}
                }
              }
            }
          }
        },
        120,
        12,
        0,
        "acc01"
      )

    [loan_no] = bank.loan_book.accounts["acc01"]

    {:ok, bank} = Bank.make_loan_payment(bank, loan_no, "acc01", 10)

    assert Bank.get_account(bank, "loan").deposit == 110
    assert Bank.get_account(bank, "acc01").deposit == 110
  end
end
