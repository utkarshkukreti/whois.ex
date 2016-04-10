defmodule WhoisTest do
  alias Whois.Record
  use ExUnit.Case
  doctest Whois


  test "lookup(\"google.com\")" do
    assert {:ok, %Record{domain: "google.com",
                         raw: raw}} = Whois.lookup("google.com")
    assert raw =~ "Domain Name: GOOGLE.COM"
    assert raw =~ "Registrar: MARKMONITOR INC."
    assert raw =~ "Name Server: NS1.GOOGLE.COM"
    assert raw =~ "Creation Date: 15-sep-1997"
  end

  test "lookup(\"google.net\")" do
    assert {:ok, %Record{domain: "google.net",
                         raw: raw}} = Whois.lookup("google.net")
    assert raw =~ "Domain Name: GOOGLE.NET"
    assert raw =~ "Registrar: MARKMONITOR INC."
    assert raw =~ "Name Server: NS1.GOOGLE.COM"
    assert raw =~ "Creation Date: 15-mar-1999"
  end

  test "lookup(\"google.org\")" do
    assert {:ok, %Record{domain: "google.org",
                         raw: raw}} = Whois.lookup("google.org")
    assert raw =~ "Domain Name: GOOGLE.ORG"
    assert raw =~ "Sponsoring Registrar: MarkMonitor Inc."
    assert raw =~ "Name Server: NS1.GOOGLE.COM"
    assert raw =~ "Creation Date: 1998-10-21"
  end
end
