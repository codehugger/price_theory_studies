defmodule PlayerSupervisor do
  use Supervisor

  def start_link([]) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Supervisor.init([Player], strategy: :one_for_one)
  end

  # Start a Player process and add it to supervision
  def add_player(player_name, game_id) do
    # Note that the second arg to start_child/2 must be an Enumerable
    Supervisor.start_child(__MODULE__, [{player_name, game_id}])
  end

  # Terminate a Player process and remove it from supervision
  def remove_llayer(player_pid) do
    Supervisor.terminate_child(__MODULE__, player_pid)
  end

  # Nice utility method to check which processes are under supervision
  def children do
    Supervisor.which_children(__MODULE__)
  end

  # Nice utility method to count processes under supervision
  def count_children do
    Supervisor.count_children(__MODULE__)
  end
end
