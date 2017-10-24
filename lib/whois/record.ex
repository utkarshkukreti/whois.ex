defmodule Whois.Record do
  defstruct [:domain, :raw, :nameservers, :registrar,
             :created_at, :updated_at, :expires_at]

  @type t :: %__MODULE__{domain: String.t,
                         raw: String.t,
                         nameservers: [String.t],
                         registrar: String.t,
                         created_at: NaiveDateTime.t,
                         updated_at: NaiveDateTime.t,
                         expires_at: NaiveDateTime.t}

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
          %{record | created_at: parse_dt(created_at) || record.created_at}
        "Updated Date: " <> updated_at ->
          %{record | updated_at: parse_dt(updated_at) || record.updated_at}
        "Expiration Date: " <> expires_at ->
          %{record | expires_at: parse_dt(expires_at) || record.expires_at}
        "Registry Expiry Date: " <> expires_at ->
          %{record | expires_at: parse_dt(expires_at) || record.expires_at}
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

  defp parse_dt(string) do
    case NaiveDateTime.from_iso8601(string) do
      {:ok, datetime} -> datetime
      {:error, _} -> nil
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
