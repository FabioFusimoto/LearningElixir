defmodule Todo.Server do
    use GenServer
    require Todo.List

    def start do
        GenServer.start(__MODULE__, nil)
    end

    def add_entry(pid, entry) do
        GenServer.cast(pid, {:add_entry, entry})
    end

    def entries(pid, date) do
        GenServer.call(pid, {:entries, date})
    end

    def update_entry(pid, id, updater_fn) do
        GenServer.cast(pid, {:update_entry, id, updater_fn})
    end

    def init(_) do
        {:ok, Todo.List.new()}
    end

    def handle_cast({:add_entry, entry}, todo_list) do
        {:noreply, Todo.List.add_entry(todo_list, entry)}
    end

    def handle_cast({:update_entry, id, updater_fn}, todo_list) do
        {:noreply, Todo.List.update_entry(todo_list, id, updater_fn)}
    end

    def handle_call({:entries, date}, _,  todo_list) do
        {:reply, Todo.List.entries(todo_list, date), todo_list}
    end
end
