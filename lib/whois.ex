defmodule Whois do
  alias Whois.{Record, Server}

  @doc """
  Queries the appropriate WHOIS server for the domain name `domain` and returns
  a `{:ok, %Whois.Record{}}` tuple on success, and `{:error, reason}` on
  failure.
  """
  @spec lookup(String.t) :: {:ok, Record.t} | {:error, atom}
  def lookup(domain) do
    case Server.for(domain) do
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
