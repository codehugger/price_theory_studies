defmodule Government do
  defmodule State do
    defstruct [:name]
  end

  use Agent

  def start_link(name), do: Agent.start_link(fn -> %State{name: name} end)
end
