defmodule MultiDict do
  def new(), do: %{}

  def add_entry(dict, key, value) do
    Map.update(
      dict,
      key,
      [value],
      fn [values] -> [value | values] end
    )
  end

  def entries(dict, key) do
    Map.get(dict, key, [])
  end
end

defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      fn entry, acc ->
        add_entry(acc, entry)
      end
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(
      todo_list.entries,
      todo_list.auto_id,
      entry
    )
    %TodoList{
      todo_list |
      entries: new_entries,
      auto_id: todo_list.auto_id + 1
    }
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(todo_list, id, updater_fn) do
    case Map.fetch(todo_list.entries, id) do
      :error ->
        todo_list
      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fn.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end
end
