defmodule TodoList do
  use GenServer

  # Client API
  def start do
    {:ok, todo_list} = GenServer.start(__MODULE__, [])
    todo_list
  end

  def add_task(todo_list, task) when is_binary(task) do
    GenServer.cast(todo_list, {:add, task})
  end

  def delete_all_tasks(todo_list) do
    GenServer.cast(todo_list, {:delete_all})
  end

  def delete_task(todo_list, task) do
    GenServer.cast(todo_list, {:delete, task})
  end

  def list_tasks(todo_list) do
    GenServer.call(todo_list, {:list})
  end

  # Server API
  def handle_cast({:add, task}, tasks) do
    {:noreply, [task | tasks]}
  end

  def handle_cast({:delete_all}, _tasks) do
    {:noreply, []}
  end

  def handle_cast({:delete, task}, tasks) do
    {:noreply, tasks -- [task]}
  end

  def handle_call({:list}, _from, tasks) do
    {:reply, tasks, tasks}
  end
end
