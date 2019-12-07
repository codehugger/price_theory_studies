defmodule GeneralLedgerTest do
  use ExUnit.Case

  alias Threadneedle.Core.{Account, GeneralLedger, Ledger}

  doctest Threadneedle.Core.GeneralLedger

  test "should pass audit on valid ledger deposits following assets = equities + liabilities" do
    ledger = %GeneralLedger{
      ledgers: %{
        "assets" => %Ledger{
          account_type: "asset",
          ledger_type: "cash",
          name: "assets",
          accounts: %{"acc01" => %Account{account_no: "acc01", deposit: 10}}
        },
        "liabilities" => %Ledger{
          account_type: "liability",
          ledger_type: "deposit",
          name: "liabilities",
          accounts: %{"acc02" => %Account{account_no: "acc02", deposit: 5}}
        },
        "equities" => %Ledger{
          account_type: "equity",
          ledger_type: "capital",
          name: "equities",
          accounts: %{"acc03" => %Account{account_no: "acc03", deposit: 5}}
        }
      }
    }

    assert GeneralLedger.audit(ledger)
  end

  test "should not pass audit on invalid ledger deposits following assets = equities + liabilities" do
    ledger = %GeneralLedger{
      ledgers: %{
        "assets" => %Ledger{
          account_type: "asset",
          ledger_type: "cash",
          name: "assets",
          accounts: %{"acc01" => %Account{account_no: "acc01", deposit: 5}}
        },
        "liabilities" => %Ledger{
          account_type: "liability",
          ledger_type: "deposit",
          name: "liabilities",
          accounts: %{"acc02" => %Account{account_no: "acc02", deposit: 5}}
        },
        "equities" => %Ledger{
          account_type: "equity",
          ledger_type: "capital",
          name: "equities",
          accounts: %{"acc03" => %Account{account_no: "acc03", deposit: 5}}
        }
      }
    }

    refute GeneralLedger.audit(ledger)
  end

  test "should not pass audit if there are duplicate accounts within ledgers" do
    ledger = %GeneralLedger{
      ledgers: %{
        "assets" => %Ledger{
          account_type: "asset",
          ledger_type: "cash",
          name: "assets",
          accounts: %{"acc01" => %Account{account_no: "acc01", deposit: 5}}
        },
        "liabilities" => %Ledger{
          account_type: "liability",
          ledger_type: "deposit",
          name: "liabilities",
          accounts: %{"acc01" => %Account{account_no: "acc01", deposit: 5}}
        }
      }
    }

    assert GeneralLedger.audit(ledger) == false
  end

  test "should report deposits total for all accounts" do
    ledger = %GeneralLedger{
      ledgers: %{
        "ledger01" => %Ledger{
          account_type: "liability",
          ledger_type: "deposit",
          name: "ledger01",
          accounts: %{"acc01" => %Account{account_no: "acc01", deposit: 5}}
        },
        "ledger02" => %Ledger{
          account_type: "liability",
          ledger_type: "deposit",
          name: "ledger02",
          accounts: %{"acc02" => %Account{account_no: "acc02", deposit: 5}}
        }
      }
    }

    assert GeneralLedger.deposits_total(ledger) == 10
  end
end
