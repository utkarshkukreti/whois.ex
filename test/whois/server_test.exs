defmodule Whois.ServerTest do
  use ExUnit.Case, async: true

  test "handles .com" do
    assert {:ok, %Whois.Server{host: host}} = Whois.Server.for("example.com")
    assert host == "whois.verisign-grs.com"
  end

  test "handles subdomains" do
    {:ok, no_subdomain} = Whois.Server.for("example.com")
    assert {:ok, ^no_subdomain} = Whois.Server.for("foo.example.com")
    assert {:ok, ^no_subdomain} = Whois.Server.for("foo.bar.baz.example.com")
  end
end
