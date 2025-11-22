# Whois [![Hex.pm](https://img.shields.io/hexpm/v/whois)](https://hex.pm/packages/whois) [![Build and Test](https://github.com/utkarshkukreti/whois.ex/actions/workflows/elixir-build-and-test.yml/badge.svg)](https://github.com/utkarshkukreti/whois.ex/actions/workflows/elixir-build-and-test.yml) [![Elixir Quality Checks](https://github.com/utkarshkukreti/whois.ex/actions/workflows/elixir-quality-checks.yml/badge.svg)](https://github.com/utkarshkukreti/whois.ex/actions/workflows/elixir-quality-checks.yml) [![Elixir Type Linting](https://github.com/utkarshkukreti/whois.ex/actions/workflows/elixir-dialyzer.yml/badge.svg)](https://github.com/utkarshkukreti/whois.ex/actions/workflows/elixir-dialyzer.yml) [![Code coverage](https://codecov.io/gh/utkarshkukreti/whois.ex/graph/badge.svg?token=Xe9iuK8f63)](https://codecov.io/gh/utkarshkukreti/whois.ex)

A pure Elixir WHOIS client and parser.

WHOIS information includes things like which registrar a domain is registered with,
who the contacts for the domain are, when the domain was first registered, when its
registration expires, when the DNS record was last updated, and more (but see the 
"Caveats" section below).

This library supports querying the WHOIS server for a large number of top-level
domains, including but not limited to:

- `.com`
- `.net`
- `.org`
- `.app`
- `.dev`
- `.io`
- `.info`
- `.me`
- `.com.au`
- `.com.br`
- `.africa`
- `.de`
- `.fr`
- `.im`
- `.lv`
- `.no`
- `.pl`
- `.se`
- `.ua`

## Caveats

WHOIS records are not a true standard, and they are first and foremost intended
for humans to interpret. Each TLD may return records in a slightly different format,
and even where the format is consistent, registrars may offer privacy protection
for contact information and addresses.

For some TLDs (especially country-specific TLDs in the European Union), most
WHOIS information is considered private, and the respective WHOIS servers will return
limited information, or even none at all (resulting in `{:error, :no_data_provided}`).
For this reason, it's not always possible to distinguish between cases where the
domain is registered (but our WHOIS queries are blocked), versus cases where the domain
is not registered at all.

The result of all this is that even when you get a success result from `Whois.lookup/1`,
the field(s) you're interested in may be `nil`. In some cases this may be because
we simply haven't implemented parsing for the TLD in question (`.co.uk` and `.ac.uk`
are big outstanding examples of this), but more often it's simply the case that the
TLD's WHOIS server doesn't offer that information.

## Installation

Add whois to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:whois, "~> 0.4"},
  ]
end
```

## Usage

With little exception, `Whois.lookup/1` is the only entry point you'll care about in the library.

It will choose the appropriate WHOIS server to contact, retrieve the DNS record for your domain,
and return a parsed version of it.

Note that the domain you pass in must be *just* a domain, without any subdomain, protocol
or path. For instance, `"google.com"` is correct, but not `"www.google.com"` or
`https://google.com`. (If you have a URL, you can use the [domainatrex][] library to 
extract just the domain.)

[domainatrex](https://github.com/zensavona/domainatrex)

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

### Cutting a release

1. Update `mix.exs`
2. Update the version in the `README.md` (if applicable)
3. Update the `CHANGELOG.md` with release notes
4. Use the GitHub UI to [tag a new release with those release notes](https://github.com/utkarshkukreti/whois.ex/releases/new)
5. Run `mix hex.publish`
