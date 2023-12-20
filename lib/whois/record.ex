defmodule Whois.Record do
  @moduledoc """
  A parsed WHOIS record.
  """
  alias Whois.Contact

  defstruct [
    :domain,
    :raw,
    :nameservers,
    :status,
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
          status: [String.t()],
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
      status: [],
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
        case split_key_and_value(line) do
          {key, value} ->
            case String.downcase(key) do
              n when n in ["domain name", "domain"] ->
                %{record | domain: value}

              ns when ns in ["name server", "nserver"] ->
                %{record | nameservers: record.nameservers ++ [value]}

              s when s in ["domain status", "status"] ->
                %{record | status: record.status ++ [value]}

              r when r in ["registrar", "registrar handle"] ->
                %{record | registrar: value}

              "sponsoring registrar" ->
                %{record | registrar: value}

              c when c in ["creation date", "created"] ->
                %{record | created_at: parse_dt(value) || record.created_at}

              u when u in ["updated date", "modified", "last updated", "changed"] ->
                %{record | updated_at: parse_dt(value) || record.updated_at}

              e when e in ["expiration date", "expires", "registry expiry date"] ->
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

    # remove duplicate entries and the icann link that comes with it "clienttransferprohibited https://icann.org/epp#clienttransferprohibited"
    status =
      record.status
      |> Enum.flat_map(&String.split/1)
      |> Enum.reject(fn
        <<"http", _rest::binary>> -> true
        <<"(http", _rest::binary>> -> true
        _ -> false
      end)
      |> Enum.uniq()

    %{record | nameservers: nameservers, status: status}
  end

  def split_key_and_value(line) do
    line
    |> String.trim()
    |> String.split(":", parts: 2, trim: true)
    |> Enum.map(&String.trim/1)
    |> case do
      # Some records are formatted as:
      # Key...........: Value
      [key, value] -> {String.trim_trailing(key, "."), value}
      _ -> nil
    end
  end

  defp parse_dt(string) do
    case NaiveDateTime.from_iso8601(string) do
      {:ok, datetime} -> datetime
      {:error, :invalid_format} -> parse_date_as_dt(string)
    end
  end

  defp parse_date_as_dt(string) do
    with {:ok, %Date{} = date} <- Date.from_iso8601(string),
         {:ok, datetime} <- NaiveDateTime.new(date, Time.new!(0, 0, 0)) do
      datetime
    else
      _ -> nil
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
      %{contact | key => value}
    else
      contact
    end
  end
end

defimpl Inspect, for: Whois.Record do
  def inspect(%Whois.Record{} = record, opts) do
    record
    |> Map.put(:raw, "…")
    |> Inspect.Any.inspect(opts)
  end
end
