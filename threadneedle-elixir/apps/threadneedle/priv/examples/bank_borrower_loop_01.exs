alias Threadneedle.Core.Bank

defmodule SimpleBank do
  use Agent

  def start_link(_opts \\ []) do
    Agent.start_link(fn -> %{bank: Bank.new(), employees: []} end, name: __MODULE__)
  end

  def add_employee(name) do
    update_bank(fn x -> x |> Bank.add_deposit_account(name) end)
    Agent.update(__MODULE__, &%{bank: &1.bank, employees: [name | &1.employees]})
  end

  def make_cash_deposit(account_no, amount) do
    update_bank(fn x -> x |> Bank.make_cash_deposit(account_no, amount) end)
  end

  def make_capital_deposit(amount) do
    update_bank(fn x -> x |> Bank.make_capital_deposit(amount) end)
  end

  def make_loan_payment(loan_no, account_no) do
    update_bank(fn x -> x |> Bank.make_loan_payment(loan_no, account_no) end)
  end

  def request_loan(loan_no, account_no, amount, duration, interest_rate) do
    update_bank(fn x ->
      x |> Bank.request_loan(loan_no, account_no, "loan", amount, duration, interest_rate)
    end)
  end

  def get_account(account_no) do
    Bank.get_account(value().bank, account_no)
  end

  def get_loan(loan_no) do
    Bank.get_loan(value().bank, loan_no)
  end

  def pay_salaries(salary) do
    Enum.each(employees(), fn x ->
      if Bank.get_account(bank(), "interest_income").deposit >= salary do
        update_bank(fn y ->
          y |> Bank.transfer("interest_income", x, salary, "Salary payment to '#{x}'")
        end)
      end
    end)
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end

  def employees do
    value().employees
  end

  def bank do
    value().bank
  end

  defp update_bank(func) do
    Agent.update(__MODULE__, &%{bank: func.(&1.bank), employees: &1.employees})
  end
end

SimpleBank.start_link()
SimpleBank.make_capital_deposit(1000)

SimpleBank.add_employee("borrower1")
SimpleBank.make_cash_deposit("borrower1", 100)

n = 100
account_no = "borrower1"
salary = 2

Enum.each(1..n, fn x ->
  loan_no = "borrower1-#{x}"

  IO.puts("===================================================================")
  IO.puts("BEGIN CYCLE #{x}")
  IO.puts("===================================================================")

  IO.inspect(SimpleBank.get_account("borrower1"))
  IO.inspect(SimpleBank.get_account("interest_income"))
  IO.inspect(SimpleBank.get_account("loan"))
  IO.inspect(SimpleBank.get_account("cash"))
  IO.inspect(SimpleBank.get_account("capital"))

  SimpleBank.request_loan(loan_no, account_no, 1000, 12, 3.0)

  IO.puts("-------------------------------------------------------------------")
  IO.inspect(SimpleBank.get_account("borrower1"))
  IO.inspect(SimpleBank.get_account("interest_income"))
  IO.inspect(SimpleBank.get_account("loan"))
  IO.inspect(SimpleBank.get_account("cash"))
  IO.inspect(SimpleBank.get_account("capital"))
  IO.puts("-------------------------------------------------------------------")

  # IO.inspect(SimpleBank.get_loan("borrower1-#{x}"))

  SimpleBank.make_loan_payment(loan_no, account_no)
  SimpleBank.pay_salaries(salary)
  SimpleBank.make_loan_payment(loan_no, account_no)
  SimpleBank.pay_salaries(salary)
  SimpleBank.make_loan_payment(loan_no, account_no)
  SimpleBank.pay_salaries(salary)
  SimpleBank.make_loan_payment(loan_no, account_no)
  SimpleBank.pay_salaries(salary)
  SimpleBank.make_loan_payment(loan_no, account_no)
  SimpleBank.pay_salaries(salary)
  SimpleBank.make_loan_payment(loan_no, account_no)
  SimpleBank.pay_salaries(salary)
  SimpleBank.make_loan_payment(loan_no, account_no)
  SimpleBank.pay_salaries(salary)
  SimpleBank.make_loan_payment(loan_no, account_no)
  SimpleBank.pay_salaries(salary)
  SimpleBank.make_loan_payment(loan_no, account_no)
  SimpleBank.pay_salaries(salary)
  SimpleBank.make_loan_payment(loan_no, account_no)
  SimpleBank.pay_salaries(salary)
  SimpleBank.make_loan_payment(loan_no, account_no)
  SimpleBank.pay_salaries(salary)
  SimpleBank.make_loan_payment(loan_no, account_no)
  SimpleBank.pay_salaries(salary)

  IO.puts("-------------------------------------------------------------------")
  IO.inspect(SimpleBank.get_account("borrower1"))
  IO.inspect(SimpleBank.get_account("interest_income"))
  IO.inspect(SimpleBank.get_account("loan"))
  IO.inspect(SimpleBank.get_account("cash"))
  IO.inspect(SimpleBank.get_account("capital"))

  IO.puts("===================================================================")
  IO.puts("END CYCLE #{x}")
  IO.puts("===================================================================")
  IO.puts("\n\n\n\n\n")
end)
