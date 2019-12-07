defmodule Threadneedle.Core.TaxPolicy do
  @moduledoc """
  A tax policy defines a mathematical rule to calculate how much tax should be collected from a defined entity type.

  ## Examples

  Can be created from various sources using `new/1` including Map, KeywordList, List and JSON string.

      iex> TaxPolicy.new(~s[{
      ...>   "name": "Personal Salary Tax (with minimum income)",
      ...>   "entity_type": "person",
      ...>   "qualifier": "x > 100",
      ...>   "rule": "(x - 100) * 0.45",
      ...>   "target": "salary"
      ...> }])
      %Threadneedle.Core.TaxPolicy{
        entity_type: "person",
        name: "Personal Salary Tax (with minimum income)",
        qualifier: "x > 100",
        rule: "(x - 100) * 0.45",
        target: "salary"
      }

  The following keys are required

    - `name`
    - `entity_type` defaults to `"any"`
    - `qualifier` defaults to `"x"`
    - `rule` defaults to `"0"`
    - `target` defaults to `"any"`
  """

  use StructBuilder

  defstruct [:name, entity_type: "any", qualifier: "x", rule: "0", target: "any"]
end
