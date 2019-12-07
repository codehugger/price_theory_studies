defmodule Threadneedle.Boundary.Simulation do
  use GenServer, restart: :temporary

  defmodule State do
    defstruct [:name, regions: %{}, step_count: 0]
  end

  def start_link(args) do
    name = Keyword.fetch!(args, :name)
    GenServer.start_link(__MODULE__, args, name: name)
  end

  def init(args), do: init(args, %State{})

  defp init([{:name, name}], %State{} = state) do
    Registry.register(Threadneedle.SimulationRegistry, name, self())
    {:ok, %{state | name: name}}
  end

  defp init([_ | t], state), do: init(t, state)

  def add_region(sim, [{:name, name}]) when is_pid(sim) and is_atom(name) do
    GenServer.call(sim, {:add_region, name})
  end

  def get_region(sim, name) when is_pid(sim) and is_atom(name) do
    GenServer.call(sim, {:get_region, name})
  end

  def step_simulation(sim) when is_pid(sim) do
    GenServer.call(sim, :step_simulation)
  end

  def handle_call({:add_region, name}, _from, %State{name: sim_name, regions: regions} = state) do
    {:ok, pid} = Threadneedle.Boundary.Region.start_link(name: :"#{sim_name}_#{name}")

    state =
      state
      |> Map.put(:regions, Map.put(regions, name, pid))

    {:reply, state, state}
  end

  def handle_call({:get_region, name}, _from, %State{regions: regions} = state) do
    {:reply, Map.fetch(regions, name), state}
  end

  def handle_call(:step_simulation, _from, %State{step_count: step_count} = state) do
    with {:ok, state} <- step(:salaries, state),
         {:ok, state} <- step(:production, state),
         {:ok, state} <- step(:debts, state),
         {:ok, state} <- step(:purchase, state) do
      {:reply, state, Map.put(state, :step_count, step_count + 1)}
    else
      {:halt, reason, state} -> {:stop, :normal, state, reason}
    end
  end

  def handle_info(msg, state) do
    IO.puts("Received unexpected message: #{inspect(msg)}")
    {:noreply, state}
  end

  defp step(_step_type, %State{step_count: 5} = state) do
    {:halt, :finished, state}
  end

  defp step(step_type, state) do
    IO.inspect(step_type)
    {:ok, state}
  end
end
