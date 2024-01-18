# Changelog

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
