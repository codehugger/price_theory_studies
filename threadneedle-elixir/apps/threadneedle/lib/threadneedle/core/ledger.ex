defmodule Threadneedle.Core.Ledger do
  @moduledoc """
  A single account type double-entry bookkeeping ledger that handles and records transactions.

  ## Examples

  Can be created from various sources using `new/1` including Map, KeywordList, List and JSON string.

      iex> Ledger.new(~s({
      ...> "name": "deposit",
      ...> "ledger_type": "deposit",
      ...> "account_type": "liability",
      ...> "accounts": {"acc01": {"account_no": "acc01"}}}))
      %Ledger{
        name: "deposit",
        ledger_type: "deposit",
        account_type: "liability",
        accounts: %{"acc01" => %Account{account_no: "acc01"}}}
  """
  alias __MODULE__
  alias Threadneedle.Core.{Account, Loan, Transaction}

  @enforce_keys ~w(name ledger_type account_type)a

  # StructBuilder Mappings
  @nested_maps %{accounts: &Account.new/1, loans: &Loan.new/1, debts: &Loan.new/1}
  @nested_lists %{transactions: &Transaction.new/1}
  use StructBuilder

  @derive Jason.Encoder
  defstruct name: nil,
            account_type: nil,
            ledger_type: nil,
            accounts: %{},
            loans: %{},
            debts: %{},
            transactions: []

  @polarity %{"asset" => -1, "liability" => 1, "equity" => 1}

  @doc """
  Returns the polarity for the ledger's `account_type`.

  ### Examples

      iex> Ledger.polarity(%Ledger{name: "ledger", ledger_type: "cash", account_type: "asset"})
      -1

      iex> Ledger.polarity(%Ledger{name: "ledger", ledger_type: "deposit", account_type: "liability"})
      1
  """
  def polarity(%Ledger{} = ledger) do
    @polarity[ledger.account_type]
  end

  @doc """
  Creates a new account and adds it to `accounts` unless `account_no` is already present.
  """
  def add_account(%Ledger{} = ledger, account_no) do
    case Map.has_key?(ledger.accounts, account_no) do
      true ->
        {:error, :account_duplicate}

      _ ->
        struct!(ledger, %{
          accounts: Map.put_new(ledger.accounts, account_no, %Account{account_no: account_no})
        })
    end
  end

  @doc """
  Makes a debit transaction to an account according to the polarity defined for type. The transaction
  is then recorded.
  """
  def debit(%Ledger{} = ledger, %Transaction{amount: amount} = trans) when amount > 0 do
    case Map.has_key?(ledger.accounts, trans.deb_account_no) do
      true ->
        ledger
        |> make_deposit(trans.deb_account_no, amount * -1 * @polarity[ledger.account_type])
        |> register_transaction(trans)

      _ ->
        {:error, :account_not_found}
    end
  end

  @doc """
  Makes a credit transaction to the account according to the polarity defined for type. The transaction
  is then recorded.
  """
  def credit(%Ledger{} = ledger, %Transaction{amount: amount} = trans) when amount > 0 do
    case Map.has_key?(ledger.accounts, trans.cred_account_no) do
      true ->
        ledger
        |> make_deposit(trans.cred_account_no, trans.amount * @polarity[ledger.account_type])
        |> register_transaction(trans)

      _ ->
        {:error, :account_not_found}
    end
  end

  @doc """
  Calculate the total of a each ledger by summing up the relevant numbers for each.

    - `{ledger_type, type}`
      - `{"loan", "asset"}     -> sum of loan capitals`
      - `{"loan", _}          -> sum of loan debts`
      - `{"capital", "equity"} -> sum of deposits`
      - `{"capital", _}       -> sum of loan capitals`
      - `{"cash", _}          -> sum of deposits`
      - `{"deposit", _}       -> sum of deposits`
  """
  def total(%Ledger{} = ledger) do
    case {ledger.ledger_type, ledger.account_type} do
      {"loan", "asset"} -> loan_capitals_total(ledger)
      {"loan", _} -> loan_debts_total(ledger)
      {"capital", "equity"} -> account_deposits_total(ledger)
      {"capital", _} -> loan_capitals_total(ledger)
      {"cash", _} -> account_deposits_total(ledger)
      {"deposit", _} -> account_deposits_total(ledger)
    end
  end

  @doc """
  Adds `loan` to ledger capital loans.

  ## Examples

      iex> Ledger.add_loan(%Ledger{name: "loan", ledger_type: "loan", account_type: "asset"},
      ...> %Loan{loan_no: "loan1", owner_account_no: "acc1", capital: 100})
      %Ledger{name: "loan", ledger_type: "loan", account_type: "asset", loans: %{"loan1" =>
      %Loan{loan_no: "loan1", owner_account_no: "acc1", capital: 100}}}
  """
  def add_loan(%Ledger{ledger_type: "loan", account_type: "asset"} = ledger, %Loan{} = loan) do
    struct(ledger, loans: Map.put_new(ledger.loans, loan.loan_no, loan))
  end

  @doc """
  Adds `loan` to the account as debt. Existing debt with the same `loan_no` will not
  be overwritten.

  ## Examples

      iex> Ledger.add_debt(%Ledger{name: "loan", ledger_type: "loan", account_type: "asset"},
      ...> %Loan{loan_no: "loan1", owner_account_no: "acc1", capital: 100})
      %Ledger{name: "loan", ledger_type: "loan", account_type: "asset", debts: %{"loan1" =>
      %Loan{loan_no: "loan1", owner_account_no: "acc1", capital: 100}}}
  """
  def add_debt(%Ledger{} = ledger, %Loan{} = loan) do
    struct(ledger, debts: Map.put_new(ledger.loans, loan.loan_no, loan))
  end

  @doc """
  Returns the sum of outstanding capital for debt loans.
  """
  def loan_debts_total(%Ledger{} = ledger) do
    ledger.debts
    |> Enum.map(fn {_k, v} -> Loan.capital_outstanding(v) end)
    |> Enum.sum()
  end

  @doc """
  Returns the sum of outstanding capital for capital loans.
  """
  def loan_capitals_total(%Ledger{} = ledger) do
    ledger.loans
    |> Enum.map(fn {_k, v} -> Loan.capital_outstanding(v) end)
    |> Enum.sum()
  end

  @doc """
  Returns the sum of all deposits for accounts in ledger.
  """
  def account_deposits_total(%Ledger{} = ledger) do
    ledger.accounts
    |> Enum.map(fn {_, account} -> account.deposit end)
    |> Enum.sum()
  end

  @doc """
  Makes a scheduled payment to a loan matching `loan_no`.
  """
  def make_loan_payment(%Ledger{} = ledger, loan_no) do
    loan = ledger.loans[loan_no] |> Loan.make_payment()
    struct(ledger, loans: Map.put(ledger.loans, loan_no, loan))
  end

  @doc """
  Makes an unscheduled payment to a loan matching `loan_no` of `amount`.
  """
  def make_loan_payment(%Ledger{} = ledger, loan_no, amount) when amount > 0 do
    loan = ledger.loans[loan_no] |> Loan.make_payment(amount)
    struct(ledger, loans: Map.put(ledger.loans, loan_no, loan))
  end

  #############################################################################
  # Private
  #############################################################################

  defp make_deposit(%Ledger{} = ledger, account_no, amount) do
    case Account.make_deposit(ledger.accounts[account_no], amount) do
      {:ok, acc} ->
        struct(ledger, accounts: Map.put(ledger.accounts, account_no, acc))

      {:error, _} = error ->
        error
    end
  end

  defp register_transaction(%Ledger{} = ledger, %Transaction{} = trans) do
    struct(ledger, transactions: [trans | ledger.transactions])
  end
end
