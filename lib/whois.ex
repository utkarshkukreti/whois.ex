defmodule Whois do
  @moduledoc """
  A WHOIS client for Elixir.
  """
  alias Whois.{Record, Server}

  @type lookup_option :: {:server, String.t() | Server.t()} | {:fall_back_to_iana?, boolean}

  @doc """
  Queries the appropriate WHOIS server for the domain.

  ### Options

  - server: the WHOIS server to query. If not specified, we'll automatically
    choose the appropriate server.
  - fall_back_to_iana?: whether to fall back to the IANA WHOIS server if looking
      up the domain on the specified or default server fails. Defaults to `true`
      whenever the `:server` is not specified.

  ### Examples

      iex> {:ok, %Whois.Record{domain: "google.com"} = record} = Whois.lookup("google.com")
      iex> NaiveDateTime.after?(record.expires_at, NaiveDateTime.utc_now())
      true
  """
  @spec lookup(String.t(), [lookup_option]) :: {:ok, Record.t()} | {:error, atom}
  def lookup(domain, opts \\ []) do
    with {:ok, raw} <- lookup_raw(domain, opts),
         %Record{domain: d} = record when byte_size(d) > 0 <- Record.parse(raw) do
      {:ok, record}
    else
      %Record{} = record ->
        # We connected to the server, but got a totally garbage raw response, like:
        # > Requests of this client are not permitted. Please use https://www.nic.ch/whois/ for queries."
        # Unless the server was specified, we'll fall back to the IANA server.
        if opts[:fall_back_to_iana?] || is_nil(opts[:server]) do
          lookup(domain, server: "whois.iana.org", fall_back_to_iana?: false)
        else
          {:ok, record}
        end

      other ->
        other
    end
  end

  defp lookup_raw(domain, opts) do
    server =
      case Keyword.fetch(opts, :server) do
        {:ok, host} when is_binary(host) -> {:ok, %Server{host: host}}
        {:ok, %Server{} = server} -> {:ok, server}
        :error -> Server.for(domain)
      end

    case server do
      {:ok, %Server{host: host}} ->
        with {:ok, socket} <-
               :gen_tcp.connect(String.to_charlist(host), 43, [:binary, active: false]),
             :ok <- :gen_tcp.send(socket, [domain, "\r\n"]) do
          raw = recv(socket)

          case next_server(raw) do
            nil ->
              {:ok, raw}

            "" ->
              {:ok, raw}

            ^host ->
              {:ok, raw}

            next_server ->
              opts = opts |> Keyword.put(:server, next_server)

              with {:ok, raw2} <- lookup_raw(domain, opts) do
                {:ok, raw <> raw2}
              end
          end
        end

      {:error, _} = error ->
        error
    end
  end

  defp recv(socket, acc \\ "") do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> recv(socket, acc <> data)
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
