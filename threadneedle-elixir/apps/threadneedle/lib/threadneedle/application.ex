defmodule Threadneedle.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, [keys: :unique, name: Threadneedle.SimulationRegistry]},
      SimulationsSup,
      Threadneedle.Repo
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Threadneedle.Supervisor)
  end
end
