defmodule Whois.RecordFixtures do
  @moduledoc false

  def record_fixture(domain) do
    "../fixtures/raw/#{domain}"
    |> Path.expand(__DIR__)
    |> File.read!()
  end

  def parsed_record_fixture(domain) do
    domain
    |> record_fixture()
    |> Whois.Record.parse()
  end
end
