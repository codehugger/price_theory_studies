defmodule Gekko.Agent.Country do
  defmodule State do
    defstruct [name: "Default", government: nil]
  end

  use Agent

  def start_link(name), do: Agent.start_link(fn ->
    %State{name: name, government: Government.start_link("#{name}-gov")} end)

  def state(country) do
    Agent.get(country, fn state -> state end)
  end

  def run_cycle(country, cycle) do
    IO.puts("Country #{state(country).name} - #{cycle}")
    country
  end
end
