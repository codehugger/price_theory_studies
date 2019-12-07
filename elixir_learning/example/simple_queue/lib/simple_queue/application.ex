defmodule SimpleQueue.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    options = [
      name: SimpleQueue.Supervisor,
      strategy: :one_for_one
    ]

    DynamicSupervisor.start_link(options)
  end
end
