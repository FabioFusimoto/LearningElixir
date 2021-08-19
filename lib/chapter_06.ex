defmodule KeyValueServer do
    use GenServer

    def start do
        GenServer.start(KeyValueServer, nil)
    end

    def put(pid, key, value) do
        GenServer.cast(pid, {:put, key, value})
    end

    def get(pid, key) do
        GenServer.call(pid, {:get, key})
    end

    def init(_) do
        {:ok, %{}}
    end

    def handle_cast({:put, key, value}, state) do
        {:noreply, Map.put(state, key, value)}
    end

    def handle_call({:get, key}, _, state) do
        {:reply, Map.get(state, key), state}
    end
end

defmodule TodoGenServer do
    use GenServer
    require TodoList

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
        {:ok, TodoList.new()}
    end

    def handle_cast({:add_entry, entry}, todo_list) do
        {:noreply, TodoList.add_entry(todo_list, entry)}
    end

    def handle_cast({:update_entry, id, updater_fn}, todo_list) do
        {:noreply, TodoList.update_entry(todo_list, id, updater_fn)}
    end

    def handle_call({:entries, date}, _,  todo_list) do
        {:reply, TodoList.entries(todo_list, date), todo_list}
    end
end
