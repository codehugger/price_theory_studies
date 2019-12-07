defmodule LedgerTest do
  use ExUnit.Case

  alias Threadneedle.Core.{Account, Ledger, Loan}

  doctest Threadneedle.Core.Ledger

  test "calculates correct total for all loan asset ledgers" do
    total =
      Ledger.total(%Ledger{
        ledger_type: "loan",
        account_type: "asset",
        name: "ledger01",
        accounts: %{
          "acc01" => %Account{
            account_no: "acc01",
            deposit: 100
          }
        },
        loans: %{"loan01" => %Loan{loan_no: "loan01", capital: 200, owner_account_no: "acc01"}},
        debts: %{"loan02" => %Loan{loan_no: "loan02", capital: 300, owner_account_no: "other"}}
      })

    assert total == 200
  end

  test "calculates correct total for all loan non-asset ledgers" do
    total =
      Ledger.total(%Ledger{
        ledger_type: "loan",
        account_type: "equity",
        name: "ledger01",
        accounts: %{
          "acc01" => %Account{
            account_no: "acc01",
            deposit: 100
          }
        },
        loans: %{"loan01" => %Loan{loan_no: "loan01", capital: 200, owner_account_no: "acc01"}},
        debts: %{"loan02" => %Loan{loan_no: "loan02", capital: 300, owner_account_no: "other"}}
      })

    assert total == 300
  end

  test "calculates correct total for all capital equity ledgers" do
    total =
      Ledger.total(%Ledger{
        ledger_type: "capital",
        account_type: "equity",
        name: "ledger01",
        accounts: %{
          "acc01" => %Account{
            account_no: "acc01",
            deposit: 100
          }
        },
        loans: %{"loan01" => %Loan{loan_no: "loan01", capital: 200, owner_account_no: "acc01"}},
        debts: %{"loan02" => %Loan{loan_no: "loan02", capital: 300, owner_account_no: "other"}}
      })

    assert total == 100
  end

  test "calculates correct total for all capital non-equity ledgers" do
    total =
      Ledger.total(%Ledger{
        ledger_type: "capital",
        account_type: "asset",
        name: "ledger01",
        accounts: %{
          "acc01" => %Account{
            account_no: "acc01",
            deposit: 100
          }
        },
        loans: %{"loan01" => %Loan{loan_no: "loan01", capital: 200, owner_account_no: "acc01"}},
        debts: %{"loan02" => %Loan{loan_no: "loan02", capital: 300, owner_account_no: "other"}}
      })

    assert total == 200
  end

  test "calculates correct total for all cash ledgers" do
    total =
      Ledger.total(%Ledger{
        ledger_type: "cash",
        account_type: "asset",
        name: "ledger01",
        accounts: %{
          "acc01" => %Account{
            account_no: "acc01",
            deposit: 100
          }
        },
        loans: %{"loan01" => %Loan{loan_no: "loan01", capital: 200, owner_account_no: "acc01"}},
        debts: %{"loan02" => %Loan{loan_no: "loan02", capital: 300, owner_account_no: "other"}}
      })

    assert total == 100
  end

  test "calculates correct total for all deposit ledgers" do
    total =
      Ledger.total(%Ledger{
        ledger_type: "deposit",
        account_type: "liability",
        name: "ledger01",
        accounts: %{
          "acc01" => %Account{
            account_no: "acc01",
            deposit: 100
          }
        },
        loans: %{"loan01" => %Loan{loan_no: "loan01", capital: 200, owner_account_no: "acc01"}},
        debts: %{"loan02" => %Loan{loan_no: "loan02", capital: 300, owner_account_no: "other"}}
      })

    assert total == 100
  end
end
