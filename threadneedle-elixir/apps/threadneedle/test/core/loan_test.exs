defmodule LoanTest do
  use ExUnit.Case

  alias Threadneedle.Core.{Loan, LoanPayment}

  doctest Threadneedle.Core.Loan

  test "should calculate payment schedule correctly for simple interest" do
    {:ok, loan} =
      Loan.new(%{
        loan_no: "loan01",
        owner_account_no: "loan",
        capital: 1200,
        duration: 12,
        interest_rate: 0.10,
        loan_type: "simple"
      })

    schedule = loan.remaining_payments_scheduled

    assert round(Enum.map(schedule, fn x -> x.interest end) |> Enum.sum()) == 65
    assert round(Enum.map(schedule, fn x -> x.capital end) |> Enum.sum()) == 1200
    assert length(schedule) == 12
  end

  test "should calculate payment schedule correctly for compound interest" do
    {:ok, loan} =
      Loan.new(%{
        loan_no: "loan01",
        owner_account_no: "loan",
        capital: 1200,
        duration: 12,
        interest_rate: 0.10,
        loan_type: "compound"
      })

    schedule = loan.remaining_payments_scheduled

    assert round(Enum.map(schedule, fn x -> x.interest end) |> Enum.sum()) == 67
    assert round(Enum.map(schedule, fn x -> x.capital end) |> Enum.sum()) == 1200
    assert length(schedule) == 12
  end

  test "should report correct capital outstanding" do
    {:ok, loan} =
      Loan.new(
        loan_no: "loan01",
        owner_account_no: "loan",
        capital: 120,
        interest_rate: 0.10,
        loan_type: "simple"
      )

    assert Loan.capital_outstanding(loan) == 120
    loan = %Loan{loan | payments_made: [%LoanPayment{capital: 10, interest: 0}]}
    assert Loan.capital_outstanding(loan) == 110
  end

  test "should pop scheduled payments when a scheduled payment is made" do
    {:ok, loan} =
      Loan.new(
        loan_no: "loan01",
        owner_account_no: "loan",
        capital: 120,
        interest_rate: 0.10,
        duration: 12,
        loan_type: "simple"
      )

    assert length(loan.payments_made) == 0
    assert length(Loan.unscheduled_payments_made(loan)) == 0
    assert length(Loan.scheduled_payments_made(loan)) == 0
    assert length(loan.remaining_payments_scheduled) == 12
    assert length(loan.initial_payments_scheduled) == 12
    assert Loan.capital_outstanding(loan) == 120
    assert Loan.sum_of_interest_payments_made(loan) == 0

    {:ok, loan} = Loan.make_payment(loan)

    assert length(loan.payments_made) == 1
    assert length(Loan.unscheduled_payments_made(loan)) == 0
    assert length(Loan.scheduled_payments_made(loan)) == 1
    assert length(loan.remaining_payments_scheduled) == 11
    assert length(loan.initial_payments_scheduled) == 12
    assert Loan.capital_outstanding(loan) == 110
    assert Loan.sum_of_interest_payments_made(loan) == hd(loan.payments_made).interest
  end

  test "should recalculate schedule correctly after unscheduled payment on simple interest" do
    {:ok, loan} =
      Loan.new(
        loan_no: "loan01",
        owner_account_no: "loan",
        capital: 120,
        interest_rate: 0.10,
        duration: 12,
        loan_type: "simple"
      )

    assert length(loan.payments_made) == 0
    assert length(Loan.unscheduled_payments_made(loan)) == 0
    assert length(Loan.scheduled_payments_made(loan)) == 0
    assert length(loan.remaining_payments_scheduled) == 12
    assert Loan.capital_outstanding(loan) == 120
    assert Loan.sum_of_interest_payments_made(loan) == 0

    {:ok, loan} = Loan.make_payment(loan, 15)

    assert length(loan.payments_made) == 1
    assert length(Loan.unscheduled_payments_made(loan)) == 1
    assert length(Loan.scheduled_payments_made(loan)) == 0
    assert length(loan.remaining_payments_scheduled) == 11
    assert Loan.capital_outstanding(loan) == 105
    assert Loan.sum_of_interest_payments_made(loan) == 0
  end

  test "should recalculate schedule correctly after unscheduled payment on compound interest" do
    {:ok, loan} =
      Loan.new(
        loan_no: "loan01",
        owner_account_no: "loan",
        capital: 120,
        interest_rate: 0.10,
        duration: 12,
        loan_type: "compound"
      )

    assert length(loan.payments_made) == 0
    assert length(Loan.unscheduled_payments_made(loan)) == 0
    assert length(Loan.scheduled_payments_made(loan)) == 0
    assert length(loan.remaining_payments_scheduled) == 12
    assert Loan.capital_outstanding(loan) == 120
    assert Loan.sum_of_interest_payments_made(loan) == 0

    {:ok, loan} = Loan.make_payment(loan, 15)

    assert length(loan.payments_made) == 1
    assert length(Loan.unscheduled_payments_made(loan)) == 1
    assert length(Loan.scheduled_payments_made(loan)) == 0
    assert length(loan.remaining_payments_scheduled) == 10
    assert Loan.capital_outstanding(loan) == 105
    assert Loan.sum_of_interest_payments_made(loan) == 0
  end

  test "should handle making unscheduled payments gracefully when there are no remaining payments left" do
    {:ok, loan} =
      Loan.new(
        loan_no: "loan01",
        owner_account_no: "loan",
        capital: 120,
        interest_rate: 0,
        duration: 1,
        loan_type: "compound"
      )

    {:ok, loan} = Loan.make_payment(loan, 120)

    assert length(loan.payments_made) == 1
    assert length(Loan.unscheduled_payments_made(loan)) == 1
    assert length(Loan.scheduled_payments_made(loan)) == 0
    assert length(loan.remaining_payments_scheduled) == 0
    assert Loan.capital_outstanding(loan) == 0
    assert Loan.sum_of_interest_payments_made(loan) == 0
    assert Loan.sum_of_capital_payments_made(loan) == 120

    {:error, :loan_paid_off} = Loan.make_payment(loan, 120)

    assert length(loan.payments_made) == 1
    assert length(Loan.unscheduled_payments_made(loan)) == 1
    assert length(Loan.scheduled_payments_made(loan)) == 0
    assert length(loan.remaining_payments_scheduled) == 0
    assert Loan.capital_outstanding(loan) == 0
    assert Loan.sum_of_interest_payments_made(loan) == 0
    assert Loan.sum_of_capital_payments_made(loan) == 120
  end

  test "should handle making scheduled payments gracefully when there are no remaining payments left" do
    {:ok, loan} =
      Loan.new(
        loan_no: "loan01",
        owner_account_no: "loan",
        capital: 120,
        interest_rate: 0,
        duration: 1,
        loan_type: "compound"
      )

    {:ok, loan} = Loan.make_payment(loan)

    assert length(loan.payments_made) == 1
    assert length(Loan.unscheduled_payments_made(loan)) == 0
    assert length(Loan.scheduled_payments_made(loan)) == 1
    assert length(loan.remaining_payments_scheduled) == 0
    assert Loan.capital_outstanding(loan) == 0
    assert Loan.sum_of_interest_payments_made(loan) == 0
    assert Loan.sum_of_capital_payments_made(loan) == 120

    {:error, :loan_paid_off} = Loan.make_payment(loan)

    assert length(loan.payments_made) == 1
    assert length(Loan.unscheduled_payments_made(loan)) == 0
    assert length(Loan.scheduled_payments_made(loan)) == 1
    assert length(loan.remaining_payments_scheduled) == 0
    assert Loan.capital_outstanding(loan) == 0
    assert Loan.sum_of_interest_payments_made(loan) == 0
    assert Loan.sum_of_capital_payments_made(loan) == 120
  end
end
