defmodule Todo.Server do
    use GenServer
    require Todo.List

    def start(name) do
        GenServer.start(__MODULE__, name)
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

    def init(name) do
        {:ok, {name, Todo.Database.get(name) || Todo.List.new()}}
    end

    def handle_cast({:add_entry, entry}, {name, todo_list}) do
        new_list = Todo.List.add_entry(todo_list, entry)
        Todo.Database.store(name, new_list)
        {:noreply, {name, new_list}}
    end

    def handle_cast({:update_entry, id, updater_fn}, {name, todo_list}) do
        {:noreply, {name, Todo.List.update_entry(todo_list, id, updater_fn)}}
    end

    def handle_call({:entries, date}, _,  {name, todo_list}) do
        {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
    end
end
