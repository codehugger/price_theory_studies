defmodule Threadneedle.Core.Account do
  @moduledoc """
  A simple account that manages deposit, capital loans and loan debts.

  ## Examples

  Can be created from various sources using `new/1` including Map, KeywordList, List and JSON string.

      iex> Account.new(~s({"account_no": "account01"}))
      %Account{account_no: "account01"}

  The following keys are required

    - `account_no`
  """

  use StructBuilder

  alias __MODULE__

  @enforce_keys ~w(account_no)a

  @derive Jason.Encoder
  defstruct account_no: nil,
            deposit: 0

  @doc """
  Makes a deposit of `amount` to the account.

  ## Examples

      iex> {:ok, acc} = Account.make_deposit(%Account{account_no: "acc01", deposit: 0}, 100)
      iex> acc.deposit == 100
      true
  """
  def make_deposit(%Account{} = acc, amount) when is_number(amount) do
    result = acc.deposit + amount

    cond do
      result < 0 ->
        {:error, :insufficient_funds}

      result >= 0 ->
        {:ok, struct(acc, deposit: result)}
    end
  end
end
