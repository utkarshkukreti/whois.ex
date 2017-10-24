defmodule Whois.Record do
  defstruct [:domain, :raw, :nameservers, :registrar,
             :created_at, :updated_at, :expires_at]

  @type date :: %{day: integer,
                  month: integer,
                  year: integer}

  @type t :: %__MODULE__{domain: String.t,
                         raw: String.t,
                         nameservers: [String.t],
                         registrar: String.t,
                         created_at: date,
                         updated_at: date,
                         expires_at: date}

  @doc """
  Parses the raw WHOIS server response in `raw` into a `%Whois.Record{}`.
  """
  @spec parse(String.t) :: t
  def parse(raw) do
    record = %Whois.Record{raw: raw, nameservers: []}
    record = Enum.reduce(String.split(raw, "\n"), record, fn line, record ->
      case String.trim(line) do
        "Domain Name: " <> domain ->
          %{record | domain: domain}
        "Name Server: " <> nameserver ->
          %{record | nameservers: record.nameservers ++ [nameserver]}
        "Registrar: " <> registrar ->
          %{record | registrar: registrar}
        "Sponsoring Registrar: " <> registrar ->
          %{record | registrar: registrar}
        "Creation Date: " <> created_at ->
          %{record | created_at: parse_date(created_at) || record.created_at}
        "Updated Date: " <> updated_at ->
          %{record | updated_at: parse_date(updated_at) || record.updated_at}
        "Expiration Date: " <> expires_at ->
          %{record | expires_at: parse_date(expires_at) || record.expires_at}
        "Registry Expiry Date: " <> expires_at ->
          %{record | expires_at: parse_date(expires_at) || record.expires_at}
        _ ->
          record
      end
    end)
    nameservers =
      record.nameservers
      |> Enum.map(&String.downcase/1)
      |> Enum.uniq
    %{record | nameservers: nameservers}
  end

  defp parse_date(string) do
    case Regex.run(~r/^(\d{2})-([a-zA-Z]{3})-(\d{4})$/, string) do
      [_, day, month, year] ->
        day = String.to_integer(day)
        month = case month do
                  "jan" -> 1; "feb" -> 2; "mar" -> 3; "apr" -> 4
                  "may" -> 5; "jun" -> 6; "jul" -> 7; "aug" -> 8
                  "sep" -> 9; "oct" -> 10; "nov" -> 11; "dec" -> 12
                end
        year = String.to_integer(year)
        %{day: day, month: month, year: year}
      _ -> nil
    end
    ||
    case Regex.run(~r/^(\d{4})-(\d{2})-(\d{2})T\d{2}:\d{2}:\d{2}Z$/, string) do
      [_, year, month, day] ->
        day = String.to_integer(day)
        month = String.to_integer(month)
        year = String.to_integer(year)
        %{day: day, month: month, year: year}
      _ -> nil
    end
  end
end

defimpl Inspect, for: Whois.Record do
  def inspect(%Whois.Record{} = record, opts) do
    record
    |> Map.put(:raw, "…")
    |> Map.delete(:__struct__)
    |> Inspect.Map.inspect("Whois.Record", opts)
  end
end
