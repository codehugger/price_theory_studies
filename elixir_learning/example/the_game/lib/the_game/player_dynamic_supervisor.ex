defmodule PlayerDynamicSupervisor do
  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # Start a Player process and add it to supervision
  def add_player(player_name, game_id) do
    # Note that start_child now directly takes in a child_spec.
    child_spec = {Player, {player_name, game_id}}

    # Equivalent to:
    # child_spec = Player.child_spec({player_name, game_id})
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  # Terminate a Player process and remove it from supervision
  def remove_player(player_pid) do
    DynamicSupervisor.terminate_child(__MODULE__, player_pid)
  end

  # Nice utility method to check which processes are under supervision
  def children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  # Nice utility method to check which processes are under supervision
  def count_children do
    DynamicSupervisor.count_children(__MODULE__)
  end
end
