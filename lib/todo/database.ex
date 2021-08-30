defmodule Todo.Database do
  use GenServer

  @worker_count 3

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    workers = for n <- 0..(@worker_count - 1) do
      {:ok, pid} = Todo.DatabaseWorker.start(to_string(n))
      pid
    end

    {:ok, %{workers: workers}}
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def handle_cast({:store, key, data}, state) do
    worker_number = choose_worker(key)
    worker_pid = Enum.at(state.workers, worker_number)

    IO.inspect("Chosen database: ")
    IO.inspect(worker_pid)

    GenServer.cast(worker_pid, {:store, key, data})
    {:noreply, state}
  end

  def handle_call({:get, key}, _, state) do
    worker_number = choose_worker(key)
    worker_pid = Enum.at(state.workers, worker_number)

    {:reply, GenServer.call(worker_pid, {:get, key}), state}
  end

  def choose_worker(key) do
    :erlang.phash2(key, @worker_count)
  end
end
