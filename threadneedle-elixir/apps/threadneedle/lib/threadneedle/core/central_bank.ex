defmodule Threadneedle.Core.CentralBank do
  @moduledoc """
  A simple central bank that used double-entry bookkeeping fro handling loans and reserves for banks.

  Can be created from various sources using `new/1` including Map, KeywordList, List and JSON string.

      iex> bank_a = CentralBank.new(~s({}))
      iex> bank_b = %CentralBank{}
      ...> |> CentralBank.add_default_ledgers()
      iex> bank_a == bank_b
      true

  As can be seen from the example a call to `new/1` adds both default ledgers and singular accounts.

  The following keys are required

    - `bank_no` defaults to `"Central Bank"`
  """

  alias __MODULE__
  alias Threadneedle.Core.{Bank, GeneralLedger}

  use StructBuilder

  defstruct general_ledger: %GeneralLedger{},
            bank_no: "Central Bank"

  @doc """
  Creates an account with `account_no` in ledger with `ledger_name`.
  """
  def add_account(%CentralBank{} = cb, %Bank{} = bank) do
    ledger =
      cb.general_ledger
      |> GeneralLedger.add_ledger(bank.bank_no, "deposit", "liability")
      |> GeneralLedger.add_account(bank.bank_no, bank.bank_no)

    struct(cb, %{general_ledger: ledger})
  end

  @doc """
  Adds the default ledgers to the bank's general ledger.

  The default ledgers are
      "capital" => %Ledger{name: "capital", ledger_type: "capital", account_type: "equity"}
      "cash" => %Ledger{name: "cash", ledger_type: "cash", account_type: "asset"}
      "deposit" => %Ledger{name: "deposit", ledger_type: "deposit", account_type: "liability"}
      "ib_debt" => %Ledger{name: "ib_debt", ledger_type: "loan", account_type: "liability"}
      "interest_income" => %Ledger{name: "interest_income", ledger_type: "deposit", account_type: "liability"}
      "loan" => %Ledger{name: "loan", ledger_type: "loan", account_type: "asset"}
      "loss_provision" => %Ledger{name: "loss_provision", ledger_type: "deposit", account_type: "liability"}
      "loss_reserve" => %Ledger{name: "loss_reserve", ledger_type: "deposit", account_type: "asset"}
      "non_cash" => %Ledger{name: "non_cash", ledger_type: "deposit", account_type: "liability"}
      "reserve" => %Ledger{name: "reserve", ledger_type: "deposit", account_type: "asset"}
      "retained_earnings" => %Ledger{name: "retained_earnings", ledger_type: "deposit", account_type: "equity"}

  Singular accounts with the same name as the ledger are added to
      "capital" => %Account{account_no: "capital", deposit: 0}
      "cash" => %Account{account_no: "cash", deposit: 0}
      "ib_debt" => %Account{account_no: "ib_debt", deposit: 0}
      "interest_income" => %Account{account_no: "interest_income", deposit: 0}
      "loan" => %Account{account_no: "loan", deposit: 0}
      "loss_provision" => %Account{account_no: "loss_provision", deposit: 0}
      "reserve" => %Account{account_no: "reserve", deposit: 0}
      "retained_earnings" => %Account{account_no: "retained_earnings", deposit: 0}
      "loss_reserve" => %Account{account_no: "loss_reserve", deposit: 0}
  """
  def add_default_ledgers(%CentralBank{general_ledger: gl} = bank) do
    with(
      # Interest Income
      {:ok, gl} <- GeneralLedger.add_ledger(gl, "interest_income", "deposit", "liability"),
      {:ok, gl} <- GeneralLedger.add_account(gl, "interest_income", "interest_income"),
      # Loan
      {:ok, gl} <- GeneralLedger.add_ledger(gl, "loan", "loan", "asset"),
      {:ok, gl} <- GeneralLedger.add_account(gl, "loan", "loan"),
      # # Non-Cash
      {:ok, gl} <- GeneralLedger.add_ledger(gl, "non_cash", "deposit", "liability"),
      {:ok, gl} <- GeneralLedger.add_account(gl, "non_cash", "non_cash"),
      # # Reserve
      {:ok, gl} <- GeneralLedger.add_ledger(gl, "reserve", "deposit", "asset"),
      {:ok, gl} <- GeneralLedger.add_account(gl, "reserve", "reserve")
    ) do
      {:ok, struct(bank, %{general_ledger: gl})}
    else
      err -> {:error, err}
    end
  end

  #############################################################################
  # Private
  #############################################################################

  defp transform_parsed(%CentralBank{} = bank) do
    bank
    |> add_default_ledgers()
  end
end
