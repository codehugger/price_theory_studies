defmodule Threadneedle.Core.Transaction do
  @moduledoc """
  A standard debit/credit double-entry bookkeping transaction.

  ## Examples

  Can be created from various sources using `new/1` including Map, KeywordList, List and JSON string.

      iex> Transaction.new(~s({
      ...>   "deb_account_no": "deb01",
      ...>   "cred_account_no": "cred01",
      ...>   "amount": 1,
      ...>   "text": "..."
      ...> }))
      %Threadneedle.Core.Transaction{
        amount: 1,
        cred_account_no: "cred01",
        deb_account_no: "deb01",
        text: "..."
      }

  The following keys are required

    - `deb_account_no`
    - `cred_account_no`
    - `amount`
    - `text` defaults to `"unknown"`
  """

  @enforce_keys ~w(deb_account_no cred_account_no amount)a
  defstruct [:deb_account_no, :cred_account_no, :amount, text: "unknown"]

  use StructBuilder
end
