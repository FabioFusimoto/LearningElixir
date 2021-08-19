defmodule TodoCacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache} = Todo.Cache.start()
    person_a_pid = Todo.Cache.server_process(cache, "Person A")

    assert person_a_pid == Todo.Cache.server_process(cache, "Person A")
    assert person_a_pid != Todo.Cache.server_process(cache, "Person B")
  end

  test "to-do operations" do
    {:ok, cache} = Todo.Cache.start()

    person_a = Todo.Cache.server_process(cache, "Person A")
    Todo.Server.add_entry(person_a, %{date: ~D[2021-08-19], title: "Person A activity"})
    entries = Todo.Server.entries(person_a, ~D[2021-08-19])

    assert [%{date: ~D[2021-08-19], title: "Person A activity"}] = entries
  end
end
