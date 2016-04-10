defmodule WhoisTest do
  use ExUnit.Case
  doctest Whois

  test "lookup(\"google.com\")" do
    assert {:ok, data} = Whois.lookup("google.com")
    assert data =~ "Domain Name: GOOGLE.COM"
    assert data =~ "Registrar: MARKMONITOR INC."
    assert data =~ "Name Server: NS1.GOOGLE.COM"
    assert data =~ "Creation Date: 15-sep-1997"
  end

  test "lookup(\"google.net\")" do
    assert {:ok, data} = Whois.lookup("google.net")
    assert data =~ "Domain Name: GOOGLE.NET"
    assert data =~ "Registrar: MARKMONITOR INC."
    assert data =~ "Name Server: NS1.GOOGLE.COM"
    assert data =~ "Creation Date: 15-mar-1999"
  end

  test "lookup(\"google.org\")" do
    assert {:ok, data} = Whois.lookup("google.org")
    assert data =~ "Domain Name: GOOGLE.ORG"
    assert data =~ "Sponsoring Registrar: MarkMonitor Inc."
    assert data =~ "Name Server: NS1.GOOGLE.COM"
    assert data =~ "Creation Date: 1998-10-21"
  end
end
