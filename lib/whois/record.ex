defmodule Whois.Record do
  defstruct [:domain, :raw, :nameservers]

  def parse(domain, raw) do
    do_parse(%Whois.Record{domain: domain, raw: raw, nameservers: []},
             raw |> String.split("\n") |> Enum.map(&String.strip/1))
  end

  defp do_parse(%Whois.Record{} = record, []) do
    record
  end
  defp do_parse(%Whois.Record{nameservers: nameservers} = record,
                ["Name Server: " <> ns | rest]) do
    do_parse(%{record | nameservers: nameservers ++ [ns]}, rest)
  end
  defp do_parse(%Whois.Record{} = record, [_ | rest]) do
    do_parse(record, rest)
  end
end
