defmodule Threadneedle.Core.Person do
  @moduledoc """
  A humanoid (homo economicus) capable of borrowing, having a salary and purchase products.

  ## Examples

  Can be created from various sources using `new/1` including Map, KeywordList, List and JSON string.

      iex> Person.new(~s({"name": "person01"}))
      %Person{name: "person01"}

  The following keys are required

    - `name`
  """

  use StructBuilder

  @enforce_keys ~w(name)a
  defstruct ~w(name)a
end
