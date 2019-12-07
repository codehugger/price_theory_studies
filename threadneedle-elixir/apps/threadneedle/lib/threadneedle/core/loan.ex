defmodule Threadneedle.Core.Loan do
  @moduledoc """
  A basic loan with a payment schedule.

  ## Examples

  Can be created from various sources using `new/1` including Map, KeywordList, List and JSON string.

  """
  alias __MODULE__
  alias Threadneedle.Core.LoanPayment

  use StructBuilder

  @enforce_keys ~w(loan_no owner_account_no capital)a

  defstruct loan_no: nil,
            owner_account_no: nil,
            loan_type: "simple",
            capital: 0,
            interest_rate: 0,
            duration: 1,
            frequency: 1,
            risk_type: nil,
            payments_made: [],
            remaining_payments_scheduled: [],
            initial_payments_scheduled: []

  @doc """
  Calculates the initial and remaining payments schedules assuming no payments have been made.
  """
  def init_payments(%Loan{} = loan) do
    case calculate_payment_schedule(loan) do
      {:ok, schedule} ->
        {:ok,
         struct(loan,
           remaining_payments_scheduled: schedule,
           initial_payments_scheduled: schedule
         )}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Re-calculates the remaining payments schedule.
  """
  def update_remaining_payments(%Loan{} = loan) do
    {:ok, schedule} = calculate_payment_schedule(loan)

    struct(loan,
      remaining_payments_scheduled: schedule
    )
  end

  @doc """
  Returns all scheduled payments that have been made.
  """
  def scheduled_payments_made(%Loan{} = loan) do
    loan.payments_made
    |> Enum.filter(fn x -> x.payment_no != nil end)
  end

  @doc """
  Returns all unscheduled payments that have been made.
  """
  def unscheduled_payments_made(%Loan{} = loan) do
    loan.payments_made
    |> Enum.filter(fn x -> x.payment_no == nil end)
  end

  @doc """
  Returns the sum of capital payments made.
  """
  def sum_of_capital_payments_made(%Loan{} = loan) do
    loan.payments_made
    |> Enum.map(fn x -> x.capital end)
    |> Enum.sum()
  end

  @doc """
  Returns the sum of interest payments made.
  """
  def sum_of_interest_payments_made(%Loan{} = loan) do
    loan.payments_made
    |> Enum.map(fn x -> x.interest end)
    |> Enum.sum()
  end

  @doc """
  Returns the next scheduled payment.
  """
  def next_payment(%Loan{} = loan) do
    case loan.remaining_payments_scheduled do
      [] -> {:error, :loan_paid_off}
      [x | _] -> x
    end
  end

  @doc """
  Make an unscheduled loan payment causing the remainder of the loan to be recalculated.
  """
  def make_payment(%Loan{} = loan, amount) when amount > 0 do
    case loan.remaining_payments_scheduled do
      [] ->
        {:error, :loan_paid_off}

      [_ | _] ->
        payment = %LoanPayment{
          capital: amount,
          interest: 0,
          owner_account_no: loan.owner_account_no
        }

        {:ok,
         struct(loan, payments_made: [payment | loan.payments_made])
         |> update_remaining_payments}
    end
  end

  @doc """
  Make a scheduled payment by transferring the payment matching `payment_no` from
  remaining scheduled payments to payments made.
  """
  def make_payment(%Loan{} = loan) do
    case loan.remaining_payments_scheduled do
      [] ->
        {:error, :loan_paid_off}

      [payment | remains] ->
        {:ok,
         struct(loan,
           payments_made: [payment | loan.payments_made],
           remaining_payments_scheduled: remains
         )}
    end
  end

  @doc """
  Returns the outstanding capital for loan.
  """
  def capital_outstanding(%Loan{} = loan) do
    loan.capital - sum_of_capital_payments_made(loan)
  end

  #############################################################################
  # Private
  #############################################################################

  defp calculate_payment_schedule(%Loan{loan_type: type} = loan)
       when type in ["compound", "variable", "interbank"] do
    if loan.capital - sum_of_capital_payments_made(loan) == 0 do
      {:ok, []}
    else
      monthly_rate = loan.interest_rate / 12.0

      no_payments = div(loan.duration, loan.frequency)
      payments_made = length(scheduled_payments_made(loan))

      monthly_payment =
        case monthly_rate do
          x when x > 0 ->
            loan.capital * monthly_rate / (1 - :math.pow(1 + monthly_rate, -no_payments))

          x when x <= 0 ->
            loan.capital / no_payments
        end

      capital_remains = loan.capital - sum_of_capital_payments_made(loan)
      no_payments_remaining = trunc(:math.ceil(capital_remains / monthly_payment))

      payment_range = (payments_made + 1)..no_payments_remaining

      {schedule, _} =
        Enum.map_reduce(payment_range, {capital_remains, 0, 0}, fn i, balance ->
          {capital_remains, accumulated_interest, total_interest} = balance
          interest_amount = capital_remains * monthly_rate
          interest_payment = round(interest_amount)
          capital_payment = round(monthly_payment - interest_payment)

          # compensate for floating point errors when calculating the last payment
          capital_rounding =
            case i do
              ^no_payments_remaining -> :math.ceil(capital_remains - capital_payment)
              _ -> 0
            end

          interest_rounding =
            case i do
              ^no_payments_remaining -> :math.ceil(total_interest - accumulated_interest)
              _ -> 0
            end

          {%LoanPayment{
             payment_no: i,
             capital: round(capital_payment + capital_rounding),
             interest: round(interest_payment + interest_rounding),
             owner_account_no: loan.owner_account_no
           },
           {capital_remains - capital_payment, accumulated_interest + interest_payment,
            total_interest + interest_amount}}
        end)

      {:ok, schedule}
    end
  end

  defp calculate_payment_schedule(%Loan{loan_type: "simple"} = loan) do
    if loan.capital - sum_of_capital_payments_made(loan) == 0 do
      []
    else
      monthly_rate = loan.interest_rate / 12.0

      no_payments = div(loan.duration, loan.frequency)
      payments_made = length(scheduled_payments_made(loan))
      monthly_payment = loan.capital / no_payments

      capital_remains = loan.capital - sum_of_capital_payments_made(loan)
      no_payments_remaining = trunc(:math.ceil(capital_remains / monthly_payment))
      payment_range = (payments_made + 1)..no_payments_remaining

      {schedule, _} =
        Enum.map_reduce(payment_range, {capital_remains, 0}, fn i, balance ->
          {capital_remains, interest_remains} = balance
          interest_payment = capital_remains * monthly_rate

          # compensate for floating point error when calculating last payment
          capital_rounding =
            case i do
              ^no_payments_remaining -> capital_remains - monthly_payment
              _ -> 0
            end

          interest_rounding =
            case i do
              ^no_payments_remaining -> interest_remains - interest_payment
              _ -> 0
            end

          {%LoanPayment{
             payment_no: i,
             capital: round(monthly_payment + capital_rounding),
             interest: round(interest_payment + interest_rounding),
             owner_account_no: loan.owner_account_no
           }, {capital_remains - monthly_payment, 0}}
        end)

      {:ok, schedule}
    end
  end

  defp calculate_payment_schedule(%Loan{loan_type: _} = loan), do: loan

  defp transform_parsed(%Loan{} = loan) do
    init_payments(loan)
  end
end
