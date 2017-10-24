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
    assert_dt record.created_at, ~D[1997-09-15]
    assert_dt record.updated_at, ~D[2011-07-20]
    assert_dt record.expires_at, ~D[2020-09-14]
  end

  test "parse google.net" do
    record = parse("google.net")
    assert record.domain == "GOOGLE.NET"
    assert record.nameservers == ["ns1.google.net",
                                  "ns2.google.net",
                                  "ns3.google.net",
                                  "ns4.google.net"]
    assert record.registrar == "MarkMonitor Inc."
    assert_dt record.created_at, ~D[1999-03-15]
    assert_dt record.updated_at, ~D[2017-09-07]
    assert_dt record.expires_at, ~D[2018-03-15]
  end

  test "parse google.org" do
    record = parse("google.org")
    assert record.domain == "GOOGLE.ORG"
    assert Enum.sort(record.nameservers) == ["ns1.google.com",
                                             "ns2.google.com",
                                             "ns3.google.com",
                                             "ns4.google.com"]
    assert record.registrar == "MarkMonitor Inc."
    assert_dt record.created_at, ~D[1998-10-21]
    assert_dt record.updated_at, ~D[2017-09-18]
    assert_dt record.expires_at, ~D[2018-10-20]
  end

  defp parse(domain) do
    "../fixtures/raw/#{domain}"
    |> Path.expand(__DIR__)
    |> File.read!
    |> Whois.Record.parse
  end

  defp assert_dt(datetime, date) do
    assert NaiveDateTime.to_date(datetime) == date
  end
end
