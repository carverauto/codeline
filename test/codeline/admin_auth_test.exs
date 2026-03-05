defmodule Codeline.AdminAuthTest do
  use ExUnit.Case, async: true

  alias Codeline.CommandParser
  alias Codeline.Protocol

  test "admin code validation" do
    assert CommandParser.admin_code_valid?("secret", "secret")
    refute CommandParser.admin_code_valid?("bad", "secret")
  end

  test "protocol transitions for admin auth success and failure" do
    state = %{Protocol.initial() | mode: :admin_auth}

    {success_state, success_actions} = Protocol.handle_line(state, "secret", "secret")
    assert success_state.mode == :admin
    assert {:prompt, :admin} in success_actions

    {failure_state, failure_actions} = Protocol.handle_line(state, "wrong", "secret")
    assert failure_state.mode == :main
    assert {:prompt, :main} in failure_actions
  end
end
