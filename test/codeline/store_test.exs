defmodule Codeline.StoreTest do
  use ExUnit.Case, async: false

  setup do
    :ok = Codeline.Store.clear_codes()
    :ok = Codeline.Store.set_motd("hello")
    :ok
  end

  test "stores and lists code entries in insertion order" do
    assert :ok = Codeline.Store.add_code("first")
    assert :ok = Codeline.Store.add_code("second")

    assert Codeline.Store.list_codes() == ["first", "second"]
  end

  test "can clear all code entries" do
    :ok = Codeline.Store.add_code("one")
    :ok = Codeline.Store.clear_codes()

    assert Codeline.Store.list_codes() == []
  end

  test "reads and updates MOTD" do
    assert Codeline.Store.get_motd() == "hello"

    assert :ok = Codeline.Store.set_motd("new motd")
    assert Codeline.Store.get_motd() == "new motd"
  end
end
