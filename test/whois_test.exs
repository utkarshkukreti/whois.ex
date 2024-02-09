defmodule WhoisTest do
  use ExUnit.Case, async: true

  setup do
    wait()
  end

  @tag :live
  test "lookup/1" do
    assert {:ok, record} = Whois.lookup("google.com")
    assert record.domain == "google.com"

    for type <- [:administrator, :registrant, :technical] do
      assert record.contacts[type].organization == "Google LLC"
      assert record.contacts[type].state == "CA"
      assert record.contacts[type].country == "US"
    end
  end

  @tag :live
  test "lookup/2 with custom :server" do
    server = "whois.markmonitor.com"
    assert {:ok, record} = Whois.lookup("google.com", server: server)
    assert record.domain == "google.com"

    wait()
    server = %Whois.Server{host: "whois.markmonitor.com"}
    assert {:ok, record} = Whois.lookup("google.com", server: server)
    assert record.domain == "google.com"
  end

  @tag :live
  test "lookup/2 provides a clear error for live TLDs that aren't amenable to robots" do
    assert {:error, :no_data_provided} = Whois.lookup("michaelruoss.ch")
  end

  @tag :live
  test "lookup/1 can check .africa domains" do
    assert {:ok, record} = Whois.lookup("mche.africa")
    assert record.domain == "mche.africa"
    assert record.created_at == ~N[2023-12-20T07:45:20.00]
    assert %NaiveDateTime{} = record.expires_at
  end

  @tag :live
  test "lookup/1 can check .me domains" do
    assert {:ok, record} = Whois.lookup("aswinmohan.me")
    assert record.domain == "aswinmohan.me"
    assert record.created_at == ~N[2019-10-19 13:16:19]
    assert %NaiveDateTime{} = record.expires_at
  end

  @tag :live
  test "lookup/1 can check .de domains" do
    assert {:ok, record} = Whois.lookup("spiegel.de")
    assert record.domain == "spiegel.de"
    assert record.status == ["connect"]

    assert record.nameservers == [
             "pns101.cloudns.net",
             "pns102.cloudns.net",
             "pns103.cloudns.net",
             "pns104.cloudns.net"
           ]

    refute record.created_at
    assert %NaiveDateTime{} = record.updated_at
    refute record.expires_at
  end

  @tag :live
  test "lookup/1 can check .io domains" do
    assert {:ok, record} = Whois.lookup("rumdash.io")
    assert record.domain == "rumdash.io"
    assert record.registrar == "Cloudflare, Inc."
    assert record.created_at == ~N[2022-11-20 17:43:37]
    assert %NaiveDateTime{} = record.updated_at
    assert %NaiveDateTime{} = record.expires_at
  end

  @tag :live
  test "lookup/1 can deal with domains that incorrectly point to fake WHOIS servers" do
    assert {:ok, record} = Whois.lookup("storehub.io", recv_timeout: 5_000)
    assert record.domain == "storehub.io"
    assert record.registrar == "Pair Domains"
    assert record.created_at == ~N[2019-09-12 10:17:27]
    assert %NaiveDateTime{} = record.updated_at
    assert %NaiveDateTime{} = record.expires_at
  end

  defp wait, do: Process.sleep(2500)
end

defmodule WhoisDocTest do
  use ExUnit.Case, async: true
  @moduletag :live
  doctest Whois

  setup do
    wait()
  end

  defp wait, do: Process.sleep(2500)
end

defmodule WhoisSyncTest do
  # Can't be async due to the use of Patch
  use ExUnit.Case, async: false
  use Patch

  test "handles timeouts" do
    Patch.patch(:gen_tcp, :connect, {:ok, %{}})
    Patch.patch(:gen_tcp, :send, :ok)
    Patch.patch(:gen_tcp, :recv, {:error, :etimedout})
    assert Whois.lookup("google.com") == {:error, :timed_out}
  end

  test "handles usable records" do
    Patch.patch(Whois, :lookup_raw, {:ok, Whois.RecordFixtures.record_fixture("google.com")})

    assert {:ok, record} = Whois.lookup("google.com")
    assert record.domain == "google.com"
    assert record.created_at == ~N[1997-09-15T07:00:00]
    assert record.expires_at == ~N[2020-09-14T04:00:00]
    assert record.updated_at == ~N[2017-09-07T15:50:36]

    for type <- [:administrator, :registrant, :technical] do
      assert record.contacts[type].organization == "Google Inc."
      assert record.contacts[type].state == "CA"
      assert record.contacts[type].country == "US"
    end
  end

  test "lookup/2 provides a clear error for TLDs that aren't supported" do
    Patch.patch(Whois, :lookup_raw, {:ok, "Automated lookup for this domain is blocked."})
    assert {:error, :no_data_provided} = Whois.lookup("unsupported.com")
  end
end
