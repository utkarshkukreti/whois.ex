defmodule Whois.ServerTest do
  use ExUnit.Case, async: true

  test "supports lots of TLDs" do
    tlds = Whois.Server.all()
    assert map_size(tlds) > 1000
  end

  test "handles .com" do
    assert {:ok, %Whois.Server{host: host}} = Whois.Server.for("example.com")
    assert host == "whois.verisign-grs.com"
  end

  test "handles subdomains" do
    {:ok, dot_com} = Whois.Server.for("example.com")
    assert {:ok, ^dot_com} = Whois.Server.for("foo.example.com")
    assert {:ok, ^dot_com} = Whois.Server.for("foo.bar.baz.example.com")

    {:ok, dot_co_dot_ca} = Whois.Server.for("example.co.ca")
    assert {:ok, ^dot_co_dot_ca} = Whois.Server.for("foo.example.co.ca")
    assert {:ok, ^dot_co_dot_ca} = Whois.Server.for("foo.bar.baz.example.co.ca")
  end

  test "handles unsupported TLDs" do
    assert {:error, :unsupported_tld} = Whois.Server.for("example.notatld")
  end
end
