defmodule Gekko.Agent.World do
  alias Gekko.Agent.Country

  defmodule State do
    defstruct [
      name: "Default",
      current_cycle: 1,
      world_bank: nil,
      countries: %{},
      halted: false,
      order_of_execution: [:markets, :companies, :employees, :banks]
    ]
  end

  use Agent

  def start_link(name),do: Agent.start_link(fn -> %State{name: name} end)
  def state(world), do: Agent.get(world, fn state -> state end)
  def halted?(world), do: state(world).halted == true
  def running?(world), do: !halted?(world)

  def stop (world) do
    state = Agent.get(world, fn x -> x end)
    :ok = Agent.stop(world)
    {:ok, state}
  end

  def halt(world) do
    case Agent.update(world, fn state -> %State{state | halted: true} end) do
      :ok -> {:ok, world}
      error -> error
    end
  end

  def resume(world) do
    case Agent.update(world, fn state -> %State{state | halted: false} end) do
      :ok -> {:ok, world}
      error -> error
    end
  end

  def add_country(world, country_name) do
    {:ok, country_pid} = Country.start_link(country_name)

    case Agent.update(world, fn state ->
      %State{state | countries: Map.put_new(state.countries, country_name, country_pid)}
    end) do
      :ok -> {:ok, world}
      error -> error
    end
  end

  # Simulate each country in random order
  def run_cycle(world) do
    if halted?(world) do
      {:error, {:world_halted, world}}
    else
      case Agent.update(world, fn state ->
        %State{state |
          countries: Map.new(Enum.map(Enum.shuffle(state.countries),
            fn {k, v} -> {k, Country.run_cycle(v, state.current_cycle)} end)),
          current_cycle: state.current_cycle + 1
        } end) do
        :ok -> {:ok, world}
        {:error, _} = error ->
          Agent.update(world, fn state -> %State{state | halted: true} end)
          error
      end
    end
  end
end
