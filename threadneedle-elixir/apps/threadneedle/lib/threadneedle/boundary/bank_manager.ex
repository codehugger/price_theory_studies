defmodule Threadneedle.Boundary.BankManager do
  use GenServer

  defmodule State do
    defstruct [:name, banks: %{}]
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

  def handle_info(msg, state) do
    IO.puts("Received unexpected message: #{inspect(msg)}")
    {:noreply, state}
  end
end
