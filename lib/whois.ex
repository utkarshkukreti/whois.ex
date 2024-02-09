defmodule Whois do
  @moduledoc """
  A WHOIS client for Elixir.
  """
  import Whois.Record, only: [is_empty: 1]
  alias Whois.Record
  alias Whois.Server

  @type lookup_option ::
          {:server, String.t() | Server.t()}
          | {:connect_timeout, timeout()}
          | {:recv_timeout, timeout()}

  @default_connect_timeout :timer.seconds(10)
  @default_recv_timeout :timer.seconds(10)

  @doc """
  Queries the appropriate WHOIS server for the domain.

  The domain must be *just* a domain, without any subdomain, protocol or path.
  For instance, `"google.com"` is correct, but not `"www.google.com"` or
  `https://google.com`. (If you have a URL, you can use the
  [domainatrex](https://github.com/zensavona/domainatrex) library to extract just the
  domain.)

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
  - connect_timeout: milliseconds to wait for the WHOIS server to accept our connection.
    Defaults to 10,000 ms (10 seconds).
  - recv_timeout: milliseconds to wait for the WHOIS server to reply after connecting.
    Defaults to 10,000 ms (10 seconds).

  ### Examples

      iex> {:ok, %Whois.Record{domain: "google.com"} = record} = Whois.lookup("google.com")
      iex> NaiveDateTime.compare(record.expires_at, NaiveDateTime.utc_now())
      :gt

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

    timeout = Access.get(opts, :connect_timeout, @default_connect_timeout)

    with {:ok, %Server{host: host} = server} <- server,
         {:ok, socket} <-
           :gen_tcp.connect(String.to_charlist(host), 43, [:binary, active: false], timeout),
         :ok <- :gen_tcp.send(socket, [query(server, domain), "\r\n"]),
         raw when is_binary(raw) <- recv(socket, "", opts) do
      case next_server(raw) do
        nil ->
          {:ok, raw}

        "" ->
          {:ok, raw}

        ^host ->
          {:ok, raw}

        next ->
          case lookup_raw(domain, [{:server, next} | opts]) do
            {:ok, raw2} ->
              {:ok, raw <> raw2}

            {:error, :timed_out} ->
              # Sometimes we get malformed WHOIS records where the record actually
              # includes all the information that exists, but incorrectly also
              # points to a Registrar WHOIS Server that just doesn't respond.
              # In these cases, if the record we received actually does belong to
              # the domain, we'll just return what we've got.
              if String.contains?(raw, domain) do
                {:ok, raw}
              else
                {:error, :timed_out}
              end

            error ->
              error
          end
      end
    else
      {:error, :timeout} -> {:error, :timed_out}
      error -> error
    end
  end

  @spec recv(socket :: :gen_tcp.socket(), acc :: String.t(), [lookup_option()]) ::
          String.t() | {:error, :timed_out}
  defp recv(socket, acc, opts) do
    timeout = Access.get(opts, :recv_timeout, @default_recv_timeout)

    case :gen_tcp.recv(socket, 0, timeout) do
      {:ok, data} -> recv(socket, acc <> data, opts)
      {:error, :etimedout} -> {:error, :timed_out}
      {:error, :closed} -> acc
    end
  end

  # Denic.de says:
  #
  # > To query the status of a domain, please use whois.denic – to query the technical data and
  # > the date of the last change to the domain data please use
  # > "whois -h whois.denic.de -T dn <domain.de>".
  #
  # https://www.denic.de/en/service/whois-service/
  defp query(%Server{host: "whois.denic.de"}, domain), do: "-T dn #{domain}"

  defp query(_, domain), do: domain

  defp next_server(raw) do
    raw
    |> String.split("\n")
    |> Enum.find_value(fn line ->
      line
      |> String.trim()
      |> String.downcase()
      |> case do
        "whois:" <> host -> String.trim(host)
        "whois server:" <> host -> String.trim(host)
        "registrar whois server:" <> host -> String.trim(host)
        _ -> nil
      end
    end)
    |> case do
      "http://" <> _ = url -> URI.parse(url).host
      "https://" <> _ = url -> URI.parse(url).host
      host when is_binary(host) -> remove_trailing_path(host)
      nil -> nil
    end
  end

  # Handles non-URL cases like "godaddy.com/"
  defp remove_trailing_path(next_server) do
    next_server
    |> String.split("/")
    |> List.first()
  end
end
