defmodule Todo.DatabaseWorker do
  use GenServer

  def start(folder) do
    GenServer.start(__MODULE__, folder)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def init(folder) do
    File.mkdir_p!(folder)
    {:ok, %{folder: folder}}
  end

  def handle_cast({:store, key, data}, state) do
    key
    |> file_name(state.folder)
    |> File.write(:erlang.term_to_binary(data))
    {:noreply, state}
  end

  def handle_call({:get, key}, _, state) do
    data =
      case File.read(file_name(key, state.folder)) do
        {:ok, content} -> :erlang.binary_to_term(content)
        _ -> nil
      end

    {:reply, data, state}
  end

  def file_name(key, folder) do
    Path.join(folder, to_string(key))
  end
end
