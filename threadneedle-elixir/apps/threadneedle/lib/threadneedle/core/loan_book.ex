defmodule Threadneedle.Core.LoanBook do
  alias __MODULE__

  defstruct loans: %{},
            accounts: %{}

  use StructBuilder

  def add_loan(%LoanBook{} = book, account_no, loan_no) do
    %{
      book
      | accounts: Map.update(book.accounts, account_no, [loan_no], fn x -> [loan_no | x] end),
        loans: Map.put_new(book.loans, loan_no, account_no)
    }
  end
end
