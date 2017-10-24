defmodule Whois.RecordTest do
  use ExUnit.Case
  doctest Whois.Record

  test "parse google.com" do
    record = parse("google.com")
    assert record.domain == "GOOGLE.COM"
    assert record.nameservers == ["ns1.google.com",
                                  "ns2.google.com",
                                  "ns3.google.com",
                                  "ns4.google.com"]
    assert record.registrar == "MarkMonitor Inc."
    assert record.created_at == dmy(15, 9, 1997)
    assert record.updated_at == dmy(20, 7, 2011)
    assert record.expires_at == dmy(14, 9, 2020)
  end

  test "parse google.net" do
    record = parse("google.net")
    assert record.domain == "GOOGLE.NET"
    assert record.nameservers == ["ns1.google.net",
                                  "ns2.google.net",
                                  "ns3.google.net",
                                  "ns4.google.net"]
    assert record.registrar == "MarkMonitor Inc."
    assert record.created_at == dmy(15, 3, 1999)
    assert record.updated_at == dmy(7, 9, 2017)
    assert record.expires_at == dmy(15, 3, 2018)
  end

  test "parse google.org" do
    record = parse("google.org")
    assert record.domain == "GOOGLE.ORG"
    assert Enum.sort(record.nameservers) == ["ns1.google.com",
                                             "ns2.google.com",
                                             "ns3.google.com",
                                             "ns4.google.com"]
    assert record.registrar == "MarkMonitor Inc."
    assert record.created_at == dmy(21, 10, 1998)
    assert record.updated_at == dmy(18, 9, 2017)
    assert record.expires_at == dmy(20, 10, 2018)
  end

  defp parse(domain) do
    "../fixtures/raw/#{domain}"
    |> Path.expand(__DIR__)
    |> File.read!
    |> Whois.Record.parse
  end

  defp dmy(day, month, year) do
    %{day: day, month: month, year: year}
  end
end
