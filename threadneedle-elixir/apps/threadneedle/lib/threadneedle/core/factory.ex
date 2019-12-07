defmodule Threadneedle.Core.Factory do
  @moduledoc """
  A business entity that produces goods or services to sell in markets.

  ## Examples

  Can be created from various sources using `new/1` including Map, KeywordList, List and JSON string.

      iex> Factory.new(~s({"name": "factory01"}))
      %Factory{name: "factory01"}

  The following keys are required

    - `name`
  """

  use StructBuilder

  @enforce_keys ~w(name)a
  defstruct ~w(name)a
end
