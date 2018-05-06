# Whois

Pure Elixir WHOIS client and parser.

This library currently supports querying .com, .net, and .org WHOIS servers, and
parsing the registrar, nameservers, and created_at, updated_at, and expires_at
dates.

## Installation

Add whois to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:whois, "~> 0.1.0"}]
end
```

## Usage

```elixir
iex(1)> Whois.lookup("google.com")
{:ok,
 %Whois.Record{
   contacts: %{
     administrator: %Whois.Contact{
       city: "Mountain View",
       country: "US",
       email: "dns-admin@google.com",
       fax: "+1.6502530001",
       name: "Domain Administrator",
       organization: "Google LLC",
       phone: "+1.6502530000",
       state: "CA",
       street: "1600 Amphitheatre Parkway,",
       zip: "94043"
     },
     registrant: %Whois.Contact{
       city: "Mountain View",
       country: "US",
       email: "dns-admin@google.com",
       fax: "+1.6502530001",
       name: "Domain Administrator",
       organization: "Google LLC",
       phone: "+1.6502530000",
       state: "CA",
       street: "1600 Amphitheatre Parkway,",
       zip: "94043"
     },
     technical: %Whois.Contact{
       city: "Mountain View",
       country: "US",
       email: "dns-admin@google.com",
       fax: "+1.6502530001",
       name: "Domain Administrator",
       organization: "Google LLC",
       phone: "+1.6502530000",
       state: "CA",
       street: "1600 Amphitheatre Parkway,",
       zip: "94043"
     }
   },
   created_at: ~N[1997-09-15 00:00:00],
   domain: "google.com",
   expires_at: ~N[2020-09-14 04:00:00],
   nameservers: ["ns1.google.com", "ns2.google.com", "ns3.google.com",
    "ns4.google.com"],
   raw: "…",
   registrar: "MarkMonitor, Inc.",
   updated_at: ~N[2018-02-21 10:45:07]
 }}
```
