defmodule Threadneedle.Core.LoanPayment do
  @moduledoc """
  A payment to a loan specifying the capital and interest. Further, scheduled
  payments can have a payment_no.

  Can be created from various sources using `new/1` including Map, KeywordList, List and JSON string.

      iex> LoanPayment.new(~s({"capital": 1, "interest": 1}))
      %LoanPayment{capital: 1, interest: 1}

  The following keys are required

    - `capital`
    - `interest`
  """

  use StructBuilder

  @enforce_keys ~w(capital interest)a
  defstruct ~w(payment_no capital interest owner_account_no)a
end
