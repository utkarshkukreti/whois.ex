defmodule WhoisTest do
  alias Whois.Record
  use ExUnit.Case
  doctest Whois


  test "lookup(\"google.com\")" do
    assert {:ok, %Record{domain: "google.com",
                         raw: raw} = record} = Whois.lookup("google.com")
    assert Enum.sort(record.nameservers) == ["NS1.GOOGLE.COM",
                                             "NS2.GOOGLE.COM",
                                             "NS3.GOOGLE.COM",
                                             "NS4.GOOGLE.COM"]
    assert raw =~ "Domain Name: GOOGLE.COM"
    assert raw =~ "Registrar: MARKMONITOR INC."
    assert raw =~ "Name Server: NS1.GOOGLE.COM"
    assert raw =~ "Creation Date: 15-sep-1997"
  end

  test "lookup(\"google.net\")" do
    assert {:ok, %Record{domain: "google.net",
                         raw: raw} = record} = Whois.lookup("google.net")
    assert Enum.sort(record.nameservers) == ["NS1.GOOGLE.COM",
                                             "NS2.GOOGLE.COM",
                                             "NS3.GOOGLE.COM",
                                             "NS4.GOOGLE.COM"]
    assert raw =~ "Domain Name: GOOGLE.NET"
    assert raw =~ "Registrar: MARKMONITOR INC."
    assert raw =~ "Name Server: NS1.GOOGLE.COM"
    assert raw =~ "Creation Date: 15-mar-1999"
  end

  test "lookup(\"google.org\")" do
    assert {:ok, %Record{domain: "google.org",
                         raw: raw} = record} = Whois.lookup("google.org")
    assert Enum.sort(record.nameservers) == ["NS1.GOOGLE.COM",
                                             "NS2.GOOGLE.COM",
                                             "NS3.GOOGLE.COM",
                                             "NS4.GOOGLE.COM"]
    assert raw =~ "Domain Name: GOOGLE.ORG"
    assert raw =~ "Sponsoring Registrar: MarkMonitor Inc."
    assert raw =~ "Name Server: NS1.GOOGLE.COM"
    assert raw =~ "Creation Date: 1998-10-21"
  end
end
