defmodule Example do
  def listen do
    receive do
      {:ok, "hello"} ->
        IO.puts("World")
    end

    listen()
  end

  def explode, do: exit(:kaboom)

  def run do
    Process.flag(:trap_exit, true)
    spawn_link(Example, :explode, [])

    receive do
      {:EXIT, _from_pid, reason} -> IO.puts("Exit reason: #{reason}")
    end
  end

  def run_monitored do
    {_pid, _ref} = spawn_monitor(Example, :explode, [])

    receive do
      {:DOWN, _ref, :process, _from_pid, reason} ->
        IO.puts("Exit reason: #{reason}")
    end
  end
end
