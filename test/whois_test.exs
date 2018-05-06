defmodule WhoisTest do
  use ExUnit.Case
  doctest Whois

  @tag :live
  test "lookup/1" do
    assert {:ok, record} = Whois.lookup("google.com")
    assert record.domain == "google.com"

    for type <- [:administrator, :registrant, :technical] do
      assert record.contacts[type].name == "Domain Administrator"
      assert record.contacts[type].organization == "Google LLC"
      assert record.contacts[type].city == "Mountain View"
    end
  end

  @tag :live
  test "lookup/2 with custom :server" do
    wait()
    server = "whois.markmonitor.com"
    assert {:ok, record} = Whois.lookup("google.com", server: server)
    assert record.domain == "google.com"

    wait()
    server = %Whois.Server{host: "whois.markmonitor.com"}
    assert {:ok, record} = Whois.lookup("google.com", server: server)
    assert record.domain == "google.com"
  end

  defp wait, do: Process.sleep(2500)
end
