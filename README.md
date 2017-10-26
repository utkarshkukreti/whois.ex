# Whois

Pure Elixir WHOIS client and parser.

This library currently supports querying .com, .net, and .org WHOIS servers, and
parsing the registrar, nameservers, and created_at, updated_at, and expires_at
dates.

## Installation

Add whois to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:whois, "~> 0.0.1"}]
end
```

## Usage

```elixir
iex(1)> Whois.lookup("google.com")
{:ok,
 %Whois.Record{created_at: ~N[1997-09-15 00:00:00], domain: "google.com",
  expires_at: ~N[2020-09-14 04:00:00],
  nameservers: ["ns1.google.com", "ns2.google.com", "ns3.google.com",
   "ns4.google.com"], raw: "…", registrar: "MarkMonitor, Inc.",
  updated_at: ~N[2017-09-07 08:50:36]}}
```
