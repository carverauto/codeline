defmodule Codeline.CommandParserTest do
  use ExUnit.Case, async: true

  alias Codeline.CommandParser

  test "parses main menu commands case-insensitively" do
    assert CommandParser.parse_main("post") == :post
    assert CommandParser.parse_main("LiSt") == :list
    assert CommandParser.parse_main("ADMIN") == :admin
    assert CommandParser.parse_main("quit") == :quit
  end

  test "parses help and unknown commands" do
    assert CommandParser.parse_main("?") == :help
    assert CommandParser.parse_admin("?") == :help
    assert CommandParser.parse_main("wat") == {:unknown, "WAT"}
  end
end
