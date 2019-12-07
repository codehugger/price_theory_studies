defmodule Threadneedle.Core.Market do
  @moduledoc """
  A business entity that buys and sells goods and services from factories.

  ## Examples

  Can be created from various sources using `new/1` including Map, KeywordList, List and JSON string.

      iex> Market.new(~s({"name": "market01"}))
      %Market{name: "market01"}

  The following keys are required

    - `name`
  """

  use StructBuilder

  @enforce_keys ~w(name)a
  defstruct ~w(name)a
end
