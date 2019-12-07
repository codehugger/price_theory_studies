defmodule Threadneedle.Core.Bank do
  @moduledoc """
  A basic bank entity with a general ledger capable of handling double-entry bookkeeping
  for loans and account transfers.

  ## Examples

  Can be created from various sources using `new/1` including Map, KeywordList, List and JSON string.

      iex> bank_a = Bank.new(~s({"bank_no": "bank01"}))
      iex> {:ok, bank_b} = %Bank{bank_no: "bank01"}
      ...> |> Bank.add_default_ledgers()
      iex> bank_a == bank_b
      true

  As can be seen from the example a call to `new/1` adds both default ledgers and singular accounts.

  The following keys are required

    - `bank_no`
  """

  require Logger
  alias __MODULE__
  alias Threadneedle.Core.{GeneralLedger, Loan, LoanBook}

  @enforce_keys ~w(bank_no)a
  @loan_types ~w(simple compound indexed interbank variable negam)
  @derive Jason.Encoder
  defstruct general_ledger: %GeneralLedger{},
            loan_book: %LoanBook{},
            bank_no: nil

  @nested_maps %{general_ledger: &GeneralLedger.new/1}
  use StructBuilder

  @doc """
  Creates an account with `account_no` in ledger with `ledger_name`.

  ## Examples

      iex> bank = Bank.new(bank_no: "bank01") |> Bank.add_account("deposit", "acc01")
      iex> bank.general_ledger.ledgers["deposit"].accounts["acc01"]
      %Account{account_no: "acc01"}
  """
  def add_account(%Bank{} = bank, account_no \\ nil, ledger_name \\ "deposit")
      when is_binary(account_no) and is_binary(ledger_name) do
    case GeneralLedger.add_account(bank.general_ledger, ledger_name, account_no) do
      {:ok, gl} -> {:ok, struct(bank, %{general_ledger: gl})}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Returns the account matching `account_no` or nil if not found.

      iex> Bank.new(%{bank_no: "bank01"}) |> Bank.get_account("cash")
      %Account{account_no: "cash"}
  """
  def get_account(%Bank{} = bank, account_no) do
    bank.general_ledger |> GeneralLedger.get_account(account_no)
  end

  @doc """
  Creates an account with `account_no` in the deposit ledger.

  ## Examples

      iex> {:ok, bank, account_no} = Bank.new(bank_no: "bank01") |> Bank.add_deposit_account("person01")
      iex> bank.general_ledger.ledgers["deposit"].accounts[account_no] == %Account{account_no: account_no}
      true
  """
  def add_deposit_account(%Bank{} = bank, owner) do
    account_no = "#{owner}-#{NumberGenerator.generate()}"

    case add_account(bank, account_no, "deposit") do
      {:ok, bank} -> {:ok, bank, account_no}
      err -> err
    end
  end

  @doc """
  Adds capital to the banks through a deposit to the reserve and capital.

  ## Examples

      iex> bank = Bank.new(bank_no: "bank01") |> Bank.add_deposit_account("acc01")
      iex> bank = Bank.make_cash_deposit(bank, "acc01", 100)
      iex> bank.general_ledger.ledgers["deposit"].accounts["acc01"].deposit
      100
  """
  def make_cash_deposit(%Bank{} = bank, account_no, amount, text \\ "Cash deposit") do
    bank
    |> transfer("cash", account_no, amount, text)
  end

  @doc """
  A really bad way of doing investment in the bank ... SHOULD BE REMOVED!!!

  ## Examples

      iex> bank = Bank.new(bank_no: "bank01")
      iex> bank = Bank.make_capital_deposit(bank, 100)
      iex> Bank.get_account(bank, "cash").deposit
      100
      iex> Bank.get_account(bank, "capital").deposit
      100
  """
  def make_capital_deposit(%Bank{} = bank, amount, text \\ "Capital deposit") do
    bank
    |> transfer("cash", "capital", amount, text)
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
  def add_default_ledgers(%Bank{general_ledger: gl} = bank) do
    Logger.debug("Adding default ledgers to bank")

    with(
      # Capital
      {:ok, gl} <- GeneralLedger.add_ledger(gl, "capital", "capital", "equity"),
      {:ok, gl} <- GeneralLedger.add_account(gl, "capital", "capital"),
      # Asset Cash
      {:ok, gl} <- GeneralLedger.add_ledger(gl, "cash", "cash", "asset"),
      {:ok, gl} <- GeneralLedger.add_account(gl, "cash", "cash"),
      # Deposit
      {:ok, gl} <- GeneralLedger.add_ledger(gl, "deposit", "deposit", "liability"),
      # Inter Bank Debt
      {:ok, gl} <- GeneralLedger.add_ledger(gl, "ib_debt", "loan", "liability"),
      {:ok, gl} <- GeneralLedger.add_account(gl, "ib_debt", "ib_debt"),
      # Interest Income
      {:ok, gl} <- GeneralLedger.add_ledger(gl, "interest_income", "deposit", "liability"),
      {:ok, gl} <- GeneralLedger.add_account(gl, "interest_income", "interest_income"),
      # Loan
      {:ok, gl} <- GeneralLedger.add_ledger(gl, "loan", "loan", "asset"),
      {:ok, gl} <- GeneralLedger.add_account(gl, "loan", "loan"),
      # # Loss Provision
      {:ok, gl} <- GeneralLedger.add_ledger(gl, "loss_provision", "deposit", "liability"),
      {:ok, gl} <- GeneralLedger.add_account(gl, "loss_provision", "loss_provision"),
      # # Loss Reserve
      {:ok, gl} <- GeneralLedger.add_ledger(gl, "loss_reserve", "deposit", "asset"),
      {:ok, gl} <- GeneralLedger.add_account(gl, "loss_reserve", "loss_reserve"),
      # # Non-Cash
      {:ok, gl} <- GeneralLedger.add_ledger(gl, "non_cash", "deposit", "liability"),
      {:ok, gl} <- GeneralLedger.add_account(gl, "non_cash", "non_cash"),
      # # Reserve
      {:ok, gl} <- GeneralLedger.add_ledger(gl, "reserve", "deposit", "asset"),
      {:ok, gl} <- GeneralLedger.add_account(gl, "reserve", "reserve"),
      # # Retained Earnings
      {:ok, gl} <- GeneralLedger.add_ledger(gl, "retained_earnings", "deposit", "equity"),
      {:ok, gl} <- GeneralLedger.add_account(gl, "retained_earnings", "retained_earnings")
    ) do
      {:ok, struct(bank, %{general_ledger: gl})}
    else
      err -> {:error, err}
    end
  end

  @doc """
  Transfer money from `acc_from` to `acc_to`. If either does not exist in the bank's ledger
  the money is booked as a reserve transaction.
  """
  def transfer(%Bank{} = bank, acc_from, acc_to, amount, text) when amount > 0 do
    Logger.debug(
      "Making transfer of #{amount} from '#{acc_from}' to '#{acc_to}'. Reason: #{text}"
    )

    case GeneralLedger.transfer(bank.general_ledger, acc_from, acc_to, amount, text) do
      {:ok, :internal, gl} ->
        {:ok, %Bank{bank | general_ledger: gl}}

      {:ok, :reserve_out, gl} ->
        {:ok, %Bank{bank | general_ledger: gl}}

      # TODO: transfer money out of the bank e.g. through Central Bank
      {:ok, :reserve_in, gl} ->
        {:ok, %Bank{bank | general_ledger: gl}}

      {:error, reason} ->
        {:error, reason}

      _ ->
        :error
    end
  end

  def transfer(%Bank{} = bank, _, _, amount, _) when amount == 0, do: bank

  @doc """
  Request a loan for account matching `account_no`.
  """
  def request_loan(
        %Bank{} = bank,
        amount,
        duration,
        interest_rate,
        account_no,
        type \\ "compound"
      )
      when type in @loan_types do
    # TODO: check risk profile if loan is allowed
    make_loan(bank, amount, duration, interest_rate, account_no, type)
  end

  @doc """
  Returns the loan matching `loan_no` or nil if not found.

  ## Examples

      iex> {:ok, bank, account_no} = Bank.new(%{bank_no: "bank01"}) |> Bank.add_deposit_account("person01")
      iex> bank = Bank.request_loan(bank, 1, 1, 0, account_no)
      iex> Bank.get_loan(bank, "loan01").loan_no
      "loan01"
  """
  def get_loan(%Bank{} = bank, loan_no) do
    GeneralLedger.get_loan(bank.general_ledger, loan_no)
  end

  @doc """
  Make a scheduled payment to loan with `loan_no`.
  """
  def make_loan_payment(%Bank{} = bank, loan_no, from_account_no) do
    loan = bank.general_ledger |> GeneralLedger.get_loan(loan_no)
    payment = loan |> Loan.next_payment()

    case payment do
      nil ->
        Logger.warn("Loan (no: #{loan_no}) already paid off.")
        bank

      _ ->
        gl = GeneralLedger.make_loan_payment(bank.general_ledger, loan_no)

        Logger.info(
          "Making scheduled payment (capital: #{payment.capital}, interest: #{payment.interest}) on loan (no: #{
            loan_no
          })"
        )

        bank = %{bank | general_ledger: gl}

        {:ok, bank} =
          transfer(
            bank,
            from_account_no,
            "loan",
            payment.capital,
            "Loan capital payment (scheduled): #{loan_no} - #{payment.payment_no}"
          )

        {:ok, bank} =
          transfer(
            bank,
            from_account_no,
            "interest_income",
            payment.interest,
            "Loan interest payment (scheduled): #{loan_no} - #{payment.payment_no}"
          )

        bank
    end
  end

  @doc """
  Make an unscheduled payment to loan with `loan_no` of `amount`.
  """
  def make_loan_payment(%Bank{} = bank, loan_no, from_account_no, amount) when amount > 0 do
    loan = bank.general_ledger |> GeneralLedger.get_loan(loan_no)
    gl = GeneralLedger.make_loan_payment(bank.general_ledger, loan_no, amount)

    struct(bank, general_ledger: gl)
    |> transfer(
      from_account_no,
      loan.owner_account_no,
      amount,
      "Loan capital payment (unscheduled): #{loan_no}"
    )
  end

  #############################################################################
  # Private
  #############################################################################

  defp make_loan(
         %Bank{} = bank,
         amount,
         duration,
         interest_rate,
         account_no,
         type,
         owner_account_no \\ "loan"
       )
       when type in @loan_types do
    # TODO: possibly override with a proper loan no
    # TODO: get interest rates from bank rates + central bank rate

    {:ok, loan} =
      Loan.new(%{
        loan_no: "loan-#{NumberGenerator.generate()}",
        owner_account_no: owner_account_no,
        capital: amount,
        interest_rate: interest_rate,
        duration: duration,
        loan_type: type
      })

    struct(bank,
      general_ledger: GeneralLedger.add_loan(bank.general_ledger, loan),
      loan_book: LoanBook.add_loan(bank.loan_book, account_no, loan.loan_no)
    )
    |> transfer(owner_account_no, account_no, loan.capital, "Loan #{loan.loan_no}")
  end

  @doc """
  Returns a new bank with default ledgers and singular accounts added to the general ledger.
  """
  def transform_parsed(%Bank{} = bank) do
    case add_default_ledgers(bank) do
      {:ok, bank} -> bank
      {:error, message} -> {:error, message}
      _ -> {:error, :unknown}
    end
  end

  def generate_loan_number() do
  end
end
