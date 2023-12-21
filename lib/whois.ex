defmodule Whois do
  @moduledoc """
  A WHOIS client for Elixir.
  """
  import Whois.Record, only: [is_empty: 1]
  alias Whois.Record
  alias Whois.Server

  @type lookup_option :: {:server, String.t() | Server.t()}

  @doc """
  Queries the appropriate WHOIS server for the domain.

  Returns `{:ok, record}` if we were able to look up WHOIS records (at the minimum,
  the date the domain was registered).

  Note that for some TLDs (especially country-specific TLDs in the European Union),
  WHOIS information is considered private, and the respective WHOIS servers will return
  limited information, or even none at all (resulting in `{:error, :no_data_provided}`).
  For this reason, it's not generally possible to distinguish between cases where the
  domain is registered (but our WHOIS queries are blocked), versus cases where the domain
  is not registered at all.

  ### Options

  - server: the WHOIS server to query. If not specified, we'll automatically
    choose the appropriate server.

  ### Examples

      iex> {:ok, %Whois.Record{domain: "google.com"} = record} = Whois.lookup("google.com")
      iex> NaiveDateTime.after?(record.expires_at, NaiveDateTime.utc_now())
      true

      iex> Whois.lookup("scha.ch")
      {:error, :no_data_provided}
  """
  @spec lookup(String.t(), [lookup_option]) ::
          {:ok, Record.t()} | {:error, :no_data_provided | :timed_out | :unsupported_tld}
  def lookup(domain, opts \\ []) do
    with {:ok, raw} <- lookup_raw(domain, opts),
         %Record{} = record when not is_empty(record) <- Record.parse(raw) do
      {:ok, record}
    else
      %Record{} -> {:error, :no_data_provided}
      other -> other
    end
  end

  defp lookup_raw(domain, opts) do
    server =
      case Keyword.fetch(opts, :server) do
        {:ok, host} when is_binary(host) -> {:ok, %Server{host: host}}
        {:ok, %Server{} = server} -> {:ok, server}
        :error -> Server.for(domain)
      end

    with {:ok, %Server{host: host}} <- server,
         {:ok, socket} <-
           :gen_tcp.connect(String.to_charlist(host), 43, [:binary, active: false]),
         :ok <- :gen_tcp.send(socket, [domain, "\r\n"]),
         raw when is_binary(raw) <- recv(socket) do
      case next_server(raw) do
        nil ->
          {:ok, raw}

        "" ->
          {:ok, raw}

        ^host ->
          {:ok, raw}

        next_server ->
          opts = Keyword.put(opts, :server, next_server)

          with {:ok, raw2} <- lookup_raw(domain, opts) do
            {:ok, raw <> raw2}
          end
      end
    end
  end

  @spec recv(socket :: :gen_tcp.socket(), acc :: String.t()) :: String.t() | {:error, :timed_out}
  defp recv(socket, acc \\ "") do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> recv(socket, acc <> data)
      {:error, :etimedout} -> {:error, :timed_out}
      {:error, :closed} -> acc
    end
  end

  defp next_server(raw) do
    raw
    |> String.split("\n")
    |> Enum.find_value(fn line ->
      line
      |> String.trim()
      |> String.downcase()
      |> case do
        "whois server:" <> host -> String.trim(host)
        "registrar whois server:" <> host -> String.trim(host)
        _ -> nil
      end
    end)
  end
end
