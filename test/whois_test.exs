defmodule WhoisTest do
  use ExUnit.Case
  doctest Whois

  test "lookup(\"google.com\")" do
    assert {:ok, record} = Whois.lookup("google.com")
    assert record.domain == "GOOGLE.COM"
    assert Enum.sort(record.nameservers) == ["NS1.GOOGLE.COM",
                                             "NS2.GOOGLE.COM",
                                             "NS3.GOOGLE.COM",
                                             "NS4.GOOGLE.COM"]
    assert record.registrar == "MARKMONITOR INC."
    assert record.created_at == dmy(15, 9, 1997)
    assert record.updated_at == dmy(20, 7, 2011)
    assert record.expires_at == dmy(14, 9, 2020)
  end

  test "lookup(\"google.net\")" do
    assert {:ok, record} = Whois.lookup("google.net")
    assert record.domain == "GOOGLE.NET"
    assert Enum.sort(record.nameservers) == ["NS1.GOOGLE.COM",
                                             "NS2.GOOGLE.COM",
                                             "NS3.GOOGLE.COM",
                                             "NS4.GOOGLE.COM"]
    assert record.registrar == "MARKMONITOR INC."
    assert record.created_at == dmy(15, 3, 1999)
    assert record.updated_at == dmy(12, 2, 2016)
    assert record.expires_at == dmy(15, 3, 2017)
  end

  test "lookup(\"google.org\")" do
    assert {:ok, record} = Whois.lookup("google.org")
    assert record.domain == "GOOGLE.ORG"
    assert Enum.sort(record.nameservers) == ["NS1.GOOGLE.COM",
                                             "NS2.GOOGLE.COM",
                                             "NS3.GOOGLE.COM",
                                             "NS4.GOOGLE.COM"]
    assert record.registrar == "MarkMonitor Inc."
    assert record.created_at == dmy(21, 10, 1998)
    assert record.updated_at == dmy(18, 9, 2015)
    assert record.expires_at == dmy(20, 10, 2016)
  end

  defp dmy(day, month, year) do
    %{day: day, month: month, year: year}
  end
end
