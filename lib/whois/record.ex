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

  defguard is_empty(record)
           when (not is_binary(record.domain) or byte_size(record.domain) == 0) and
                  is_nil(record.created_at)

  @type t :: %__MODULE__{
          domain: String.t() | nil,
          raw: String.t(),
          nameservers: [String.t()],
          status: [String.t()],
          registrar: String.t() | nil,
          created_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          expires_at: NaiveDateTime.t() | nil,
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

    {record, _last_continuation_header} =
      raw
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.reduce({record, nil}, &apply_line/2)

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

  defp apply_line("", {%__MODULE__{} = record, _}), do: {record, nil}

  defp apply_line(line, {%__MODULE__{} = record, last_continuation_header})
       when is_binary(line) do
    case split_key_and_value(line) do
      {key, value} ->
        case apply_key_value(record, String.downcase(key), value) do
          {:ok, updated_record} ->
            {updated_record, nil}

          :error ->
            {record, last_continuation_header}
        end

      _unsplittable_line ->
        case apply_key_value(record, last_continuation_header, line) do
          {:ok, updated_record} ->
            {updated_record, last_continuation_header}

          :error ->
            if String.ends_with?(line, ":") do
              continuation_header =
                line
                |> String.split(":", parts: 2)
                |> List.first()
                |> String.trim()
                |> String.downcase()

              {record, continuation_header}
            else
              {record, nil}
            end
        end
    end
  end

  defp apply_key_value(%__MODULE__{} = record, n, value) when n in ["domain name", "domain"] do
    {:ok, %{record | domain: String.downcase(value)}}
  end

  defp apply_key_value(%__MODULE__{} = record, ns, value)
       when ns in ["name server", "nserver", "nameservers", "servers"] do
    {:ok, %{record | nameservers: record.nameservers ++ [value]}}
  end

  defp apply_key_value(%__MODULE__{} = record, s, value) when s in ["domain status", "status"] do
    {:ok, %{record | status: record.status ++ [value]}}
  end

  defp apply_key_value(%__MODULE__{} = record, r, value)
       when r in ["registrar", "registrar handle", "registrar name", "provider"] do
    {:ok, %{record | registrar: value}}
  end

  defp apply_key_value(%__MODULE__{} = record, "sponsoring registrar", value) do
    {:ok, %{record | registrar: value}}
  end

  defp apply_key_value(%__MODULE__{} = record, c, value)
       when c in ["creation date", "created", "entry created"] do
    {:ok, %{record | created_at: parse_dt(value) || record.created_at}}
  end

  defp apply_key_value(%__MODULE__{} = record, u, value)
       when u in [
              "updated",
              "updated date",
              "modified",
              "last updated",
              "changed",
              "last modified",
              "entry updated"
            ] do
    {:ok, %{record | updated_at: parse_dt(value) || record.updated_at}}
  end

  defp apply_key_value(%__MODULE__{} = record, e, value)
       when e in [
              "expiration date",
              "expires",
              "registry expiry date",
              "expiry date",
              "renewal date",
              "registrar registration expiration date"
            ] do
    {:ok, %{record | expires_at: parse_dt(value) || record.expires_at}}
  end

  defp apply_key_value(%__MODULE__{} = record, "registrant " <> name, value) do
    {:ok, update_in(record.contacts.registrant, &parse_contact(&1, name, value))}
  end

  defp apply_key_value(%__MODULE__{} = record, "admin " <> name, value) do
    {:ok, update_in(record.contacts.administrator, &parse_contact(&1, name, value))}
  end

  defp apply_key_value(%__MODULE__{} = record, "tech " <> name, value) do
    {:ok, update_in(record.contacts.technical, &parse_contact(&1, name, value))}
  end

  defp apply_key_value(_record, _key, _value), do: :error

  defp split_key_and_value(line) do
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
    with {:ok, datetime, _} <- DateTime.from_iso8601(string),
         {:ok, utc} <- DateTime.shift_zone(datetime, "Etc/UTC") do
      DateTime.to_naive(utc)
    else
      _ -> parse_naive_dt(string)
    end
  end

  defp parse_naive_dt(string) do
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
      _ -> parse_smooshed_together_date(string)
    end
  end

  # Handles dates use on .com.br domains like 20240526
  defp parse_smooshed_together_date(string) do
    with [<<year::binary-4, month::binary-2, day::binary-2>> | _] <- String.split(string),
         {year, ""} when year > 1980 and year < 2200 <- Integer.parse(year),
         {month, ""} when month >= 1 and month <= 12 <- Integer.parse(month),
         {day, ""} when day >= 1 and day <= 31 <- Integer.parse(day),
         {:ok, date} <- Date.new(year, month, day),
         {:ok, naive} <- NaiveDateTime.new(date, Time.new!(0, 0, 0)) do
      naive
    else
      _ -> guess_date(string)
    end
  end

  defp guess_date(string) do
    case DateTimeParser.parse_datetime(string) do
      {:ok, %NaiveDateTime{} = naive} ->
        naive

      {:ok, %DateTime{} = dt} ->
        case DateTime.shift_zone(dt, "Etc/UTC") do
          {:ok, utc} -> DateTime.to_naive(utc)
          {:error, _} -> nil
        end

      {:error, _} ->
        nil
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

    if is_nil(key) do
      contact
    else
      Map.put(contact, key, value)
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
