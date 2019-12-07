defmodule Threadneedle.Core.GeneralLedger do
  @moduledoc """
  A bank's top-level ledger containing other ledgers.

  The general ledger can be audited in terms of assets, equities and liabilities.

  ## Examples

  # From JSON string

      iex> GeneralLedger.new(~s({
      ...> "ledgers": {
      ...>   "loan": {
      ...>     "name": "loan",
      ...>     "ledger_type": "loan",
      ...>     "account_type": "asset"
      ...>   }
      ...> }}))
      %GeneralLedger{
        ledgers: %{
          "loan" => %Ledger{
            name: "loan",
            ledger_type: "loan",
            account_type: "asset"
          }
        }
      }

  """
  alias __MODULE__
  alias Threadneedle.Core.{Ledger, Loan, Transaction}

  @ledger_types ~w(loan capital cash deposit)
  @account_types ~w(asset liability equity)

  @nested_maps %{ledgers: &Ledger.new/1}

  use StructBuilder

  defstruct ledgers: %{}

  @doc """
  Creates a ledger with `ledger_type` and `account_type` and adds to `ledgers`. If `name` is
  already present the existing ledger will not be overwritten.
  """
  def add_ledger(%GeneralLedger{} = gl, name, ledger_type, account_type)
      when ledger_type in @ledger_types and account_type in @account_types do
    {:ok,
     struct(gl,
       ledgers:
         Map.put_new(gl.ledgers, name, %Ledger{
           name: name,
           ledger_type: ledger_type,
           account_type: account_type
         })
     )}
  end

  @doc """
  Adds a new account to ledger matching `ledger_name`. If an account matching `account_no` is
  found in `ledgers` it will not be overwritten. If account with `account_no` is found in a ledger
  not matching `ledger_name` an error will be returned.
  """
  def add_account(%GeneralLedger{} = gl, ledger_name, account_no) do
    case gl.ledgers[ledger_name] do
      nil ->
        {:error, :ledger_not_found}

      ledger ->
        case get_ledger_by_account(gl, account_no) do
          nil ->
            ledgers =
              Map.put(
                gl.ledgers,
                ledger_name,
                Ledger.add_account(ledger, account_no)
              )

            {:ok, struct(gl, ledgers: ledgers)}

          _ ->
            {:error, :account_duplicate}
        end
    end
  end

  @doc """
  Adds `loan` as capital to account matching `account_no`.
  """
  def add_loan(%GeneralLedger{} = gl, %Loan{} = loan) do
    ledger =
      gl.ledgers["loan"]
      |> Ledger.add_loan(loan)

    %{gl | ledgers: Map.put(gl.ledgers, ledger.name, ledger)}
  end

  @doc """
  Make a scheduled payment to loan matching `loan_no`.
  """
  def make_loan_payment(%GeneralLedger{} = gl, loan_no) do
    ledger =
      get_ledger_by_loan(gl, loan_no)
      |> Ledger.make_loan_payment(loan_no)

    struct(gl, ledgers: Map.put(gl.ledgers, ledger.name, ledger))
  end

  @doc """
  Make a scheduled payment to loan matching `loan_no`.
  """
  def make_loan_payment(%GeneralLedger{} = gl, loan_no, amount) do
    ledger =
      get_ledger_by_loan(gl, loan_no)
      |> Ledger.make_loan_payment(loan_no, amount)

    struct(gl, ledgers: Map.put(gl.ledgers, ledger.name, ledger))
  end

  @doc """
  Transfer funds from `acc_from` to `acc_to`. If either is from another bank the transfer
  will be made to the `reserve` account signifying a transfer in or out of the ledger.
  """
  def transfer(%GeneralLedger{} = gl, acc_from, acc_to, amount, text) when acc_from != acc_to do
    case {get_account(gl, acc_from), get_account(gl, acc_to)} do
      # accounts are not in the ledgers
      {nil, nil} ->
        {:error, :invalid_accounts}

      # destination account not found => transfer out to reserves
      {_, nil} ->
        case post(gl, acc_from, "reserve", amount, text) do
          {:ok, gl} -> {:ok, :reserve_in, gl}
          {:error, reason} -> {:error, :reserve_in, reason}
        end

      # source account not found => transfer in to bank reserves
      {nil, _} ->
        case post(gl, "reserve", acc_to, amount, text) do
          {:ok, gl} -> {:ok, :reserve_in, gl}
          {:error, reason} -> {:error, :reserve_in, reason}
        end

      {_, _} ->
        case post(gl, acc_from, acc_to, amount, text) do
          {:ok, gl} -> {:ok, :internal, gl}
          {:error, reason} -> {:error, :internal, reason}
        end
    end
  end

  @doc """
  Post a debit/credit transaction to `gl`.
  """
  def post(%GeneralLedger{} = gl, deb_account_no, cred_account_no, amount, text)
      when deb_account_no != cred_account_no do
    trans = %Transaction{
      deb_account_no: deb_account_no,
      cred_account_no: cred_account_no,
      amount: amount,
      text: text
    }

    case {get_ledger_by_account(gl, deb_account_no), get_ledger_by_account(gl, cred_account_no)} do
      # ledgers do not exist
      {nil, nil} ->
        {:error, :ledger_not_found}

      # transfer within the same ledger
      {x, x} ->
        ledger = x |> Ledger.debit(trans) |> Ledger.credit(trans)
        {:ok, struct(gl, ledgers: gl.ledgers |> Map.put(ledger.name, ledger))}

      # transfer between different ledgers
      {x, y} ->
        deb_ledger = x |> Ledger.debit(trans)
        cred_ledger = y |> Ledger.credit(trans)

        {:ok,
         struct(gl,
           ledgers:
             gl.ledgers
             |> Map.put(deb_ledger.name, deb_ledger)
             |> Map.put(cred_ledger.name, cred_ledger)
         )}
    end
  end

  @doc """
  Returns the first ledger containing the account with `account_no`.
  """
  def get_ledger_by_account(%GeneralLedger{} = gl, account_no) do
    case gl.ledgers
         |> Enum.find(fn {_k, x} -> x.accounts[account_no] end) do
      {_, ledger} -> ledger
      nil -> nil
    end
  end

  @doc """
  Returns the first ledger containing the loan with `loan_no`.
  """
  def get_ledger_by_loan(%GeneralLedger{} = gl, loan_no) do
    case gl.ledgers
         |> Enum.find(fn {_k, x} -> x.loans[loan_no] end) do
      {_, ledger} -> ledger
      nil -> nil
    end
  end

  @doc """
  Returns the account matching `account_no`.
  """
  def get_account(%GeneralLedger{} = gl, account_no) do
    gl.ledgers
    |> Enum.map(fn {_, x} -> x.accounts[account_no] end)
    |> Enum.find(fn x -> x != nil end)
  end

  @doc """
  Returns the loan matching `loan_no`.
  """
  def get_loan(%GeneralLedger{} = gl, loan_no) do
    gl.ledgers
    |> Enum.map(fn {_, x} -> x.loans[loan_no] end)
    |> Enum.find(fn x -> x != nil end)
  end

  @doc """
  Audits `ledger` by verifying that assets are equal to liabilities + equities. Also verifies
  that each account only appears in one ledger.
  """
  def audit(%GeneralLedger{} = gl) do
    audit_accounts(gl) &&
      assets_total(gl) == equities_total(gl) + liabilities_total(gl)
  end

  @doc """
  Verifies that no account exists in more than one ledger by comparing account numbers.
  """
  def audit_accounts(%GeneralLedger{} = gl) do
    account_nos = gl.ledgers |> Enum.map(fn {_, x} -> Map.keys(x.accounts) end) |> List.flatten()

    length(account_nos) == length(Enum.uniq(account_nos))
  end

  @doc """
  Returns all accounts from all underlying ledgers.
  """
  def accounts(%GeneralLedger{} = gl) do
    gl.ledgers
    |> Enum.map(fn {_lk, x} -> x.accounts |> Enum.map(fn {_ak, y} -> y end) end)
    |> List.flatten()
  end

  @doc """
  Returns a list of asset ledgers.
  """
  def assets(%GeneralLedger{} = gl) do
    gl
    |> ledgers_of_account_type("asset")
  end

  @doc """
  Returns the total sum of all assets ledgers.
  """
  def assets_total(%GeneralLedger{} = gl) do
    gl
    |> assets
    |> Enum.map(fn x -> Ledger.total(x) end)
    |> Enum.sum()
  end

  @doc """
  Get total sum for deposits within all ledgers.
  """
  def deposits_total(%GeneralLedger{} = gl) do
    gl
    |> accounts()
    |> Enum.map(fn x -> x.deposit end)
    |> Enum.sum()
  end

  @doc """
  Returns a list of equity ledgers.
  """
  def equities(%GeneralLedger{} = gl) do
    gl |> ledgers_of_account_type("equity")
  end

  @doc """
  Returns the total sum of all equities.
  """
  def equities_total(%GeneralLedger{} = gl) do
    gl
    |> equities
    |> Enum.map(fn x -> Ledger.total(x) end)
    |> Enum.sum()
  end

  @doc """
  Returns a list from `ledgers`, with `account_type`.
  """
  def ledgers_of_account_type(%GeneralLedger{} = gl, account_type) do
    gl.ledgers
    |> Enum.filter(fn {_, v} -> v.account_type == account_type end)
    |> Enum.map(fn {_, v} -> v end)
  end

  @doc """
  Returns a list of liability ledgers.
  """
  def liabilities(%GeneralLedger{} = gl) do
    gl |> ledgers_of_account_type("liability")
  end

  @doc """
  Returns the total sum of all liabilities.
  """
  def liabilities_total(%GeneralLedger{} = gl) do
    gl
    |> liabilities
    |> Enum.map(fn x -> Ledger.total(x) end)
    |> Enum.sum()
  end
end
