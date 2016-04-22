defmodule Whois do
  alias Whois.{Record, Server}

  @type lookup_option :: {:server, String.t | Server.t}

  @doc """
  Queries the appropriate WHOIS server for the domain name `domain` and returns
  a `{:ok, %Whois.Record{}}` tuple on success, and `{:error, reason}` on
  failure.
  """
  @spec lookup(String.t, [lookup_option]) :: {:ok, Record.t} | {:error, atom}
  def lookup(domain, opts \\ []) do
    with {:ok, raw} <- lookup_raw(domain, opts) do
      {:ok, Record.parse(raw)}
    end
  end

  defp lookup_raw(domain, opts) do
    server = case Keyword.fetch(opts, :server) do
               {:ok, host} when is_binary(host) -> {:ok, %Server{host: host}}
               {:ok, %Server{} = server} -> {:ok, server}
               :error -> Server.for(domain)
             end
    case server do
      {:ok, %Server{host: host, prefix: prefix}} ->
        with {:ok, socket} <- :gen_tcp.connect(String.to_char_list(host),
                                               43,
                                               [:binary, active: false]),
             :ok <- :gen_tcp.send(socket, "#{prefix}#{domain}\r\n") do
          raw = recv(socket)
          if next_server = next_server(raw) do
            opts = opts |> Keyword.put(:server, next_server)
            with {:ok, raw2} <- lookup_raw(domain, opts) do
              {:ok, raw <> raw2}
            end
          else
            {:ok, raw}
          end
        end
      :error -> {:error, :unsupported}
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
      case String.strip(line) do
        "Whois Server: " <> host -> host
        _ -> nil
      end
    end)
  end
end
