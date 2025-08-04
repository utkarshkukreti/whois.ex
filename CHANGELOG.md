# Changelog

## v0.3.2

### Bug fixes
* [fix .me issue](https://github.com/utkarshkukreti/whois.ex/pull/45) by new contributor @manuel-rubio
* [Update registry for .in domains](https://github.com/utkarshkukreti/whois.ex/pull/58) by new contributor @ssinghi

### Dependency bumps and housekeeping
- Credo 1.7.7 -> 1.7.12
- Dialyxir 1.4.3 -> 1.4.5
- Patch 0.13.1 -> 0.16.0
- ExDoc 0.34.2 -> 0.38.2
- ExCoveralls 0.18.3 -> 0.18.5
- DateTimeParser 1.2.0 -> 1.2.1
* Remove CI for old Elixir versions, since Ubuntu 20.04 is no longer supported in GitHub Actions by @s3cur3 in https://github.com/utkarshkukreti/whois.ex/pull/53

## v0.3.1

- Fix crash when TCP receive times out (`Whois.lookup/2` now correctly returns `{:error, :timed_out}`)

## v0.3.0

- Add support for custom timeouts via the `:connect_timeout` and `:recv_timeout`
  options to `Whois.lookup/1` ([#15](https://github.com/utkarshkukreti/whois.ex/pull/15))
- Correctly fall back to the last best record for domains whose registrar 
  includes a bogus terminating WHOIS server (like `pairdomains.com`) ([#15](https://github.com/utkarshkukreti/whois.ex/pull/15))
- Add support for `.pl` domains ([#16](https://github.com/utkarshkukreti/whois.ex/pull/16))


## v0.2.1

Super embarrassing compilation fix. 👀

## v0.2.0

After a couple years of remaining static, v0.2.0 modernizes the dependencies and bumps the minimum supported Elixir version to Elixir 1.12.

v0.2.0 adds support for the following new TLDs, courtesy of a new maintainer (@s3cur3):

* .se
* .no
* .de
* .im
* .africa
* .io
* .com.au
* .com.br

It also adds a new `:status` field to the `%Whois.Record{}` by new contributor @sfusato (👋).

@sfusato also contributed a [fix for a crash when fetching a record](https://github.com/utkarshkukreti/whois.ex/pull/7).

**Full Changelog**: https://github.com/utkarshkukreti/whois.ex/compare/v0.1.1...v0.2.0
