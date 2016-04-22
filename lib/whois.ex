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
             :ok <- :gen_tcp.send(socket, "#{prefix}#{domain}\r\n"),
             do: {:ok, Record.parse(recv(socket))}
      :error -> {:error, :unsupported}
    end
  end

  defp recv(socket, acc \\ "") do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> recv(socket, acc <> data)
      {:error, :closed} -> acc
    end
  end
end
