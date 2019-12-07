defmodule Threadneedle.Boundary.Region do
  defmodule State do
    defstruct [:name, regions: %{}, bank_manager: nil]
  end

  def start_link(args) do
    name = Keyword.fetch!(args, :name)
    GenServer.start_link(__MODULE__, args, name: name)
  end

  def init(args), do: init(args, %State{})

  defp init([{:name, name} | rest], %State{} = state) when is_atom(name) do
    init(rest, %{state | name: name})
  end

  defp init([], %State{name: _name} = state) do
    {:ok, state}
  end

  defp init([_ | t], state), do: init(t, state)

  def add_bank(region, name) when is_pid(region) and is_atom(name) do
    GenServer.call(region, {:add_bank, name})
  end

  def get_bank(region, name) when is_pid(region) and is_atom(name) do
    GenServer.call(region, {:get_bank, name})
  end

  def handle_call(:get_bank_manager, _from, %State{bank_manager: manager} = state) do
    {:reply, manager, state}
  end

  def handle_info(:set_bank_manager, %State{name: region_name}, state) do
    {:ok, pid} =
      Threadneedle.Boundary.BankManager.start_link(name: :"#{region_name}_bank_manager")

    {:noreply, %{state | bank_manager: pid}}
  end

  def handle_info(msg, state) do
    IO.puts("Received unexpected message: #{inspect(msg)}")
    {:noreply, state}
  end
end
