defmodule GovernmentRules do
  defstruct state: :initialized

  def new(), do: %GovernmentRules{}

  def check(%GovernmentRules{state: state} = rules, _)
      when state in [:initialized, :operationl] do
    {:ok, rules}
  end
end
