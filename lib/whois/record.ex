defmodule Whois.Record do
  defstruct [:domain, :raw, :nameservers, :registrar,
             :created_at, :updated_at, :expires_at]

  def parse(domain, raw) do
    record = %Whois.Record{domain: domain, raw: raw, nameservers: []}
    Enum.reduce(String.split(raw, "\n"), record, fn line, record ->
      case String.strip(line) do
        "Name Server: " <> nameserver ->
          %{record | nameservers: record.nameservers ++ [nameserver]}
        "Registrar: " <> registrar ->
          %{record | registrar: registrar}
        "Sponsoring Registrar: " <> registrar ->
          %{record | registrar: registrar}
        _ ->
          record
      end
    end)
  end
end
