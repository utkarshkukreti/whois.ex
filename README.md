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
iex> Whois.lookup("google.com")
{:ok,
 %Whois.Record{created_at: %{day: 15, month: 9, year: 1997},
  domain: "GOOGLE.COM", expires_at: %{day: 14, month: 9, year: 2020},
  nameservers: ["NS1.GOOGLE.COM", "NS2.GOOGLE.COM", "NS3.GOOGLE.COM",
   "NS4.GOOGLE.COM"],
  raw: "…",
  registrar: "MARKMONITOR INC.", updated_at: %{day: 20, month: 7, year: 2011}}}
```
