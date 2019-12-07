defmodule SimulationsSup do
  use DynamicSupervisor

  @name __MODULE__

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: @name)
  end

  def start_simulation(args) when is_list(args) do
    case DynamicSupervisor.start_child(@name, {Simulation, args}) do
      {:ok, _} = sim -> sim
      {:error, _} = error -> error
    end
  end

  def stop_simulation(sim_name) when is_atom(sim_name) do
    [{_, sim}] = Registry.lookup(SimulationRegistry, sim_name)
    DynamicSupervisor.terminate_child(@name, sim)
  end

  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
