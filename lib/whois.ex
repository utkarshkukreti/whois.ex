defmodule Whois do
  alias Whois.{Record, Server}

  @type lookup_option :: {:server, String.t() | Server.t()}

  @doc """
  Queries the appropriate WHOIS server for the domain name `domain` and returns
  a `{:ok, %Whois.Record{}}` tuple on success, and `{:error, reason}` on
  failure.
  """
  @spec lookup(String.t(), [lookup_option]) :: {:ok, Record.t()} | {:error, atom}
  def lookup(domain, opts \\ []) do
    with {:ok, raw} <- lookup_raw(domain, opts) do
      {:ok, Record.parse(raw)}
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

      :error ->
        {:error, :unsupported}
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
