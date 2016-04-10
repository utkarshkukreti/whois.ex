defmodule Whois do
  alias Whois.{Record, Server}

  @servers %{
    "com" => %Server{host: 'whois.verisign-grs.com', prefix: "="},
    "net" => %Server{host: 'whois.verisign-grs.com'},
    "org" => %Server{host: 'whois.pir.org'}
  }

  @doc """
  Queries the appropriate WHOIS server for the domain name `domain` and returns
  a `{:ok, %Whois.Record{}}` tuple on success, and `{:error, reason}` on
  failure.
  """
  @spec lookup(String.t) :: {:ok, Record.t} | {:error, atom}
  def lookup(domain) do
    [_, tld] = String.split(domain, ".", parts: 2)
    %Server{host: host, prefix: prefix} = Map.fetch!(@servers, tld)
    with {:ok, socket} <- :gen_tcp.connect(host, 43, [:binary, active: false]),
         :ok <- :gen_tcp.send(socket, "#{prefix}#{domain}\r\n"),
         do: {:ok, Record.parse(recv(socket))}
  end

  defp recv(socket, acc \\ "") do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> recv(socket, acc <> data)
      {:error, :closed} -> acc
    end
  end
end
