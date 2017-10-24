defmodule WhoisTest do
  use ExUnit.Case
  doctest Whois

  @tag :live
  test "lookup/1" do
    assert {:ok, record} = Whois.lookup("google.com")
    assert record.domain == "GOOGLE.COM"
  end

  @tag :live
  test "lookup/2 with custom :server" do
    server = "whois.markmonitor.com"
    assert {:ok, record} = Whois.lookup("google.com", server: server)
    assert record.domain == "google.com"

    # Wait a while before making a request to the same server again below.
    :timer.sleep(500)

    server = %Whois.Server{host: "whois.markmonitor.com"}
    assert {:ok, record} = Whois.lookup("google.com", server: server)
    assert record.domain == "google.com"
  end
end
