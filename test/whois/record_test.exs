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

    assert record.registrar =~ "MarkMonitor, Inc."
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

    assert record.registrar =~ "MarkMonitor, Inc."
    assert_dt(record.created_at, ~D[1999-03-15])
    assert_dt(record.updated_at, ~D[2017-09-08])
    assert_dt(record.expires_at, ~D[2018-03-14])
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

    assert record.registrar =~ "MarkMonitor, Inc."
    assert_dt(record.created_at, ~D[1998-10-21])
    assert_dt(record.updated_at, ~D[2017-09-18])
    assert_dt(record.expires_at, ~D[2018-10-19])
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

  test "parse wheel.im" do
    record = parse("wheel.im")
    assert record.domain == "wheel.im"

    assert record.nameservers == [
             "ns-1031.awsdns-00.org.",
             "ns-1904.awsdns-46.co.uk.",
             "ns-297.awsdns-37.com.",
             "ns-621.awsdns-13.net."
           ]

    refute record.registrar
    refute record.created_at
    refute record.updated_at
    assert_dt(record.expires_at, ~D[2024-02-29])
  end

  test "parse a domain that refuses bot queries" do
    record = parse("jasstafel.michaelruoss.ch")
    assert Whois.Record.is_empty(record)
    refute record.domain
    assert record.nameservers == []
    refute record.registrar
    refute record.created_at
    refute record.updated_at
    refute record.expires_at
  end

  test "parse a .io domain" do
    record = parse("rumdash.io")
    refute Whois.Record.is_empty(record)
    assert record.domain == "rumdash.io"
    assert record.status == ["clientTransferProhibited"]
    assert record.nameservers == ["tara.ns.cloudflare.com", "clyde.ns.cloudflare.com"]
    assert record.registrar == "Cloudflare, Inc"
    assert_dt(record.created_at, ~D[2022-11-20])
    assert_dt(record.updated_at, ~D[2023-10-26])
    assert_dt(record.expires_at, ~D[2024-11-20])
  end

  test "parse a .com.au domain" do
    record = parse("thinkactively.com.au")
    refute Whois.Record.is_empty(record)
    assert record.domain == "thinkactively.com.au"
    assert record.status == ["serverRenewProhibited"]
    assert record.nameservers == ["dns1.alwaysdata.com", "dns2.alwaysdata.com"]
    assert record.registrar == "SYNERGY WHOLESALE ACCREDITATIONS PTY LTD"
    refute record.created_at
    assert_dt(record.updated_at, ~D[2023-09-24])
    refute record.expires_at
  end

  test "parse a .de domain" do
    record = parse("zweitag.de")
    refute Whois.Record.is_empty(record)
    assert record.domain == "zweitag.de"

    assert record.nameservers == [
             "ns1.zweitag.de 205.251.197.248",
             "ns2.zweitag.de 205.251.198.68",
             "ns3.zweitag.de 205.251.194.50",
             "ns4.zweitag.de 205.251.192.69"
           ]

    refute record.registrar
    refute record.created_at
    assert_dt(record.updated_at, ~D[2022-06-20])
    refute record.expires_at
  end

  test "parse a .com.br domain" do
    record = parse("algoltech.com.br")
    refute Whois.Record.is_empty(record)
    assert record.domain == "algoltech.com.br"
    assert record.status == ["published"]

    assert record.nameservers == [
             "ns59.domaincontrol.com",
             "ns60.domaincontrol.com"
           ]

    assert record.registrar == "GODADDY (86)"
    assert_dt(record.expires_at, ~D[2024-05-26])
  end

  test "parse a .pl domain" do
    record = parse("ftdl.pl")
    refute Whois.Record.is_empty(record)
    assert record.domain == "ftdl.pl"

    # TODO: Parse the full block of nameservers, like:
    # nameservers:     dns101.ovh.net.
    #                  ns101.ovh.net.
    assert record.nameservers == [
             "dns101.ovh.net."
           ]

    assert record.registrar ==
             String.trim("""
             OVH SAS
             2 Rue Kellermann
             59100 Roubaix
             Francja/France
             """)

    assert_dt(record.created_at, ~D[2021-01-12])
    assert_dt(record.updated_at, ~D[2024-01-10])
    assert_dt(record.expires_at, ~D[2025-01-12])
  end

  test "parse balcia.lv" do
    record = parse("balcia.lv")
    assert record.domain == "balcia.lv"
    assert record.nameservers == ["ns.online.lv", "ns2.online.lv", "ns3.online.lv"]
    refute record.registrar
    refute record.created_at
    assert_dt(record.updated_at, ~D[2024-02-09])
    refute record.expires_at
  end

  test "parse manchester.ac.uk" do
    record = parse("manchester.ac.uk")
    assert record.domain == "manchester.ac.uk"

    assert record.nameservers == [
             "ns1.manchester.ac.uk\t130.88.1.1",
             "ns2.manchester.ac.uk\t130.88.1.2",
             "ns4.ja.net"
           ]

    refute record.registrar

    # TODO: Parse the weird format dates
    # assert_dt(record.created_at, ~D[2003-09-17])
    # assert_dt(record.updated_at, ~D[2022-12-05])
    # assert_dt(record.expires_at, ~D[2025-01-05])
  end

  defp parse(domain), do: Whois.RecordFixtures.parsed_record_fixture(domain)

  defp assert_dt(%NaiveDateTime{} = datetime, date) do
    assert NaiveDateTime.to_date(datetime) == date
  end

  defp assert_dt(nil, _date) do
    raise "expected a date"
  end
end
