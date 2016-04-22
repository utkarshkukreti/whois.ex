defmodule WhoisTest do
  use ExUnit.Case
  doctest Whois

  test "lookup/1" do
    assert {:ok, record} = Whois.lookup("google.com")
    assert record.domain == "GOOGLE.COM"
  end

  test "lookup/2 with custom :server" do
    server = "whois.markmonitor.com"
    assert {:ok, record} = Whois.lookup("google.com", server: server)
    assert record.domain == "google.com"

    server = %Whois.Server{host: "whois.markmonitor.com"}
    assert {:ok, record} = Whois.lookup("google.com", server: server)
    assert record.domain == "google.com"
  end
end
