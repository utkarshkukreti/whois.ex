defmodule Whois.RecordTest do
  use ExUnit.Case
  doctest Whois.Record

  alias Whois.Contact

  test "parse google.com" do
    record = parse("google.com")
    assert record.domain == "google.com"

    assert record.nameservers == [
             "ns1.google.com",
             "ns2.google.com",
             "ns3.google.com",
             "ns4.google.com"
           ]

    assert record.registrar == "MarkMonitor, Inc."
    assert_dt(record.created_at, ~D[1997-09-15])
    assert_dt(record.updated_at, ~D[2017-09-07])
    assert_dt(record.expires_at, ~D[2020-09-14])
  end

  test "parse google.net" do
    record = parse("google.net")
    assert record.domain == "google.net"

    assert record.nameservers == [
             "ns1.google.net",
             "ns2.google.net",
             "ns3.google.net",
             "ns4.google.net"
           ]

    assert record.registrar == "MarkMonitor, Inc."
    assert_dt(record.created_at, ~D[1999-03-15])
    assert_dt(record.updated_at, ~D[2017-09-08])
    assert_dt(record.expires_at, ~D[2018-03-15])
  end

  test "parse google.org" do
    record = parse("google.org")
    assert record.domain == "google.org"

    assert Enum.sort(record.nameservers) == [
             "ns1.google.com",
             "ns2.google.com",
             "ns3.google.com",
             "ns4.google.com"
           ]

    assert record.registrar == "MarkMonitor, Inc."
    assert_dt(record.created_at, ~D[1998-10-21])
    assert_dt(record.updated_at, ~D[2017-09-18])
    assert_dt(record.expires_at, ~D[2018-10-20])
  end

  test "parse google.{com,net,org}" do
    for domain <- ["google.com", "google.net", "google.org"] do
      record = parse(domain)

      {street, phone, fax} =
        case domain do
          "google.com" -> {"1600 Amphitheatre Parkway,", "+1.6502530000", "+1.6502530001"}
          "google.net" -> {"1600 Amphitheatre Parkway", "+1.6506234000", "+1.6506188571"}
          "google.org" -> {"1600 Amphitheatre Parkway", "+1.6506234000", "+1.6506188571"}
        end

      for key <- [:registrant, :administrator, :technical] do
        assert Map.get(record.contacts, key) == %Contact{
                 name: "DNS Admin",
                 organization: "Google Inc.",
                 street: street,
                 city: "Mountain View",
                 state: "CA",
                 zip: "94043",
                 country: "US",
                 phone: phone,
                 fax: fax,
                 email: "dns-admin@google.com"
               }
      end
    end
  end

  defp parse(domain) do
    "../fixtures/raw/#{domain}"
    |> Path.expand(__DIR__)
    |> File.read!()
    |> Whois.Record.parse()
  end

  defp assert_dt(datetime, date) do
    assert NaiveDateTime.to_date(datetime) == date
  end
end
