defmodule Pooly.WorkerSupervisor do
  use DynamicSupervisor

  # Public API

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child() do
    spec = {SampleWorker, restart: :permanent}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def init(init_args) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      max_restarts: 5,
      max_seconds: 5,
      extra_arguments: [init_args]
    )
  end
end
