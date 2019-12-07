defmodule Player do
  use GenServer

  def init({player_name, game_id}) do
    {:ok, %{name: player_name, game_id: game_id}}
  end

  # Insert this start_link/2 method, which intercepts the extra `[]`
  # argument from the Supervisor and molds it back to correct form.
  def start_link([], {player_name, game_id}) do
    start_link({player_name, game_id})
  end

  # Original implementation
  def start_link({player_name, game_id}) do
    GenServer.start_link(__MODULE__, {player_name, game_id}, name: {:global, "player:#{player_name}"})
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def handle_call(:get, _from, state) do
    {:reply, {:ok, state}, state}
  end
end
