defmodule Whois.Record do
  alias Whois.Contact

  defstruct [
    :domain,
    :raw,
    :nameservers,
    :registrar,
    :created_at,
    :updated_at,
    :expires_at,
    :contacts
  ]

  @type t :: %__MODULE__{
          domain: String.t(),
          raw: String.t(),
          nameservers: [String.t()],
          registrar: String.t(),
          created_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t(),
          expires_at: NaiveDateTime.t(),
          contacts: %{
            registrant: Contact.t(),
            administrator: Contact.t(),
            technical: Contact.t()
          }
        }

  @doc """
  Parses the raw WHOIS server response in `raw` into a `%Whois.Record{}`.
  """
  @spec parse(String.t()) :: t
  def parse(raw) do
    record = %Whois.Record{
      raw: raw,
      nameservers: [],
      contacts: %{
        registrant: %Contact{},
        administrator: %Contact{},
        technical: %Contact{}
      }
    }

    record =
      raw
      |> String.split("\n")
      |> Enum.reduce(record, fn line, record ->
        line
        |> String.trim()
        |> String.split(":", parts: 2)
        |> case do
          [name, value] ->
            name = name |> String.trim() |> String.downcase()
            value = value |> String.trim()

            case name do
              "domain name" ->
                %{record | domain: value}

              "name server" ->
                %{record | nameservers: record.nameservers ++ [value]}

              "registrar" ->
                %{record | registrar: value}

              "sponsoring registrar" ->
                %{record | registrar: value}

              "creation date" ->
                %{record | created_at: parse_dt(value) || record.created_at}

              "updated date" ->
                %{record | updated_at: parse_dt(value) || record.updated_at}

              "expiration date" ->
                %{record | expires_at: parse_dt(value) || record.expires_at}

              "registry expiry date" ->
                %{record | expires_at: parse_dt(value) || record.expires_at}

              "registrant " <> name ->
                update_in(record.contacts.registrant, &parse_contact(&1, name, value))

              "admin " <> name ->
                update_in(record.contacts.administrator, &parse_contact(&1, name, value))

              "tech " <> name ->
                update_in(record.contacts.technical, &parse_contact(&1, name, value))

              _ ->
                record
            end

          _ ->
            record
        end
      end)

    nameservers =
      record.nameservers
      |> Enum.map(&String.downcase/1)
      |> Enum.uniq()

    %{record | nameservers: nameservers}
  end

  defp parse_dt(string) do
    case NaiveDateTime.from_iso8601(string) do
      {:ok, datetime} -> datetime
      {:error, _} -> nil
    end
  end

  defp parse_contact(%Contact{} = contact, name, value) do
    key =
      case name do
        "name" -> :name
        "organization" -> :organization
        "street" -> :street
        "city" -> :city
        "state/province" -> :state
        "postal code" -> :zip
        "country" -> :country
        "phone" -> :phone
        "fax" -> :fax
        "email" -> :email
        _ -> nil
      end

    if key do
      contact |> Map.put(key, value)
    else
      contact
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
