defmodule Game do
  use GenServer

  def init(game_id) do
    {:ok, %{game_id: game_id}}
  end

  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id, name: {:global, "game:#{game_id}"})
  end

  def add_player(pid, player_name) do
    GenServer.call(pid, {:add_player, player_name})
  end

  # def handle_call({:add_player, player_name}, _from, %{game_id: game_id} = state) do
  #   # Uh oh, we started this process but it's not under supervision!
  #   start_status = Player.start_link({player_name, game_id})
  #   {:reply, start_status, state}
  # end

  def handle_call({:add_player, player_name}, _from, %{game_id: game_id} = state) do
    # Now we replace this with supervised management
    start_status = PlayerSupervisor.add_player(player_name, game_id)
    {:reply, start_status, state}
  end
end
