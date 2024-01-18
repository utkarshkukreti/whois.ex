# Whois [![Build and Test](https://github.com/utkarshkukreti/whois.ex/actions/workflows/elixir-build-and-test.yml/badge.svg)](https://github.com/utkarshkukreti/whois.ex/actions/workflows/elixir-build-and-test.yml) [![Elixir Quality Checks](https://github.com/utkarshkukreti/whois.ex/actions/workflows/elixir-quality-checks.yml/badge.svg)](https://github.com/utkarshkukreti/whois.ex/actions/workflows/elixir-quality-checks.yml) [![Elixir Type Linting](https://github.com/utkarshkukreti/whois.ex/actions/workflows/elixir-dialyzer.yml/badge.svg)](https://github.com/utkarshkukreti/whois.ex/actions/workflows/elixir-dialyzer.yml) [![Code coverage](https://codecov.io/gh/utkarshkukreti/whois.ex/graph/badge.svg?token=Xe9iuK8f63)](https://codecov.io/gh/utkarshkukreti/whois.ex)

Pure Elixir WHOIS client and parser.

This library currently supports querying .com, .net, and .org WHOIS servers, and
parsing the registrar, nameservers, and created_at, updated_at, and expires_at
dates.

## Installation

Add whois to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:whois, "~> 0.2"}]
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

## Development

### Preparing a PR

There are a handful of code quality checks that CI runs. To run them locally, you can use:

```sh
mix check
```

This does *not* adequately test the TCP connection to real Whois servers, because the GitHub Actions IPs are generally blocked by the servers our "live" (i.e., full end-to-end) tests rely on. Full full test coverage, you'll need to run `mix test --include live` locally.

### Updating the list of Whois servers

The `priv` directory contains a Makefile that will download the latest TLD reference file from the web and parse it into a structure we can use at compile time. Run it like this:

```sh
cd priv
make clean
make tld.json
make tld.csv
```
