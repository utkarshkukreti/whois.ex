defmodule WhoisTest do
  use ExUnit.Case
  doctest Whois

  test "lookup(\"google.com\")" do
    assert {:ok, _} = Whois.lookup("google.com")
  end
end
