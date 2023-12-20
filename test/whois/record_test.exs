defmodule Whois.RecordTest do
  use ExUnit.Case, async: true
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

    assert record.status == [
             "clientDeleteProhibited",
             "clientTransferProhibited",
             "clientUpdateProhibited",
             "serverDeleteProhibited",
             "serverTransferProhibited",
             "serverUpdateProhibited"
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

    assert record.status == [
             "clientDeleteProhibited",
             "clientTransferProhibited",
             "clientUpdateProhibited",
             "serverDeleteProhibited",
             "serverTransferProhibited",
             "serverUpdateProhibited"
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

    assert record.status == [
             "clientDeleteProhibited",
             "clientTransferProhibited",
             "clientUpdateProhibited",
             "serverDeleteProhibited",
             "serverTransferProhibited",
             "serverUpdateProhibited"
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

  test "parse amoi.se" do
    record = parse("amoi.se")
    assert record.domain == "amoi.se"

    assert record.nameservers == [
             "ed.ns.cloudflare.com 199.27.135.11",
             "chin.ns.cloudflare.com 173.245.58.84"
           ]

    assert record.status == ["ok"]

    assert record.registrar == "Dotkeeper AB"
    assert_dt(record.created_at, ~D[2020-03-11])
    assert_dt(record.updated_at, ~D[2023-05-24])
    assert_dt(record.expires_at, ~D[2024-03-11])
  end

  test "parse amoi.no" do
    record = parse("amoi.no")
    assert record.domain == "amoi.no"
    assert Enum.empty?(record.nameservers)
    assert record.registrar == "REG802-NORID"
    assert_dt(record.created_at, ~D[2023-11-06])
    assert_dt(record.updated_at, ~D[2023-11-06])
    refute record.expires_at
  end

  test "parse jasstafel.michaelruoss.ch" do
    record = parse("jasstafel.michaelruoss.ch")

    # This is a quirk of the IANA server
    assert record.domain == "CH"

    assert record.nameservers == [
             "a.nic.ch 130.59.31.41 2001:620:0:ff:0:0:0:56",
             "b.nic.ch 130.59.31.43 2001:620:0:ff:0:0:0:58",
             "d.nic.ch 194.0.25.39 2001:678:20:0:0:0:0:39",
             "e.nic.ch 194.0.17.1 2001:678:3:0:0:0:0:1",
             "f.nic.ch 194.146.106.10 2001:67c:1010:2:0:0:0:53"
           ]

    refute record.registrar
    assert_dt(record.created_at, ~D[1987-05-20])
    assert_dt(record.updated_at, ~D[2023-11-30])
    refute record.expires_at
  end

  defp parse(domain) do
    "../fixtures/raw/#{domain}"
    |> Path.expand(__DIR__)
    |> File.read!()
    |> Whois.Record.parse()
  end

  defp assert_dt(%NaiveDateTime{} = datetime, date) do
    assert NaiveDateTime.to_date(datetime) == date
  end

  defp assert_dt(nil, _date) do
    raise "expected a date"
  end
end
