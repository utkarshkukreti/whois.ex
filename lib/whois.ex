defmodule Whois do
  @servers %{
    "com" => %{host: 'whois.verisign-grs.com', prefix: "="},
    "net" => %{host: 'whois.verisign-grs.com'},
    "org" => %{host: 'whois.pir.org'}
  }

  def lookup(domain) do
    [_, tld] = String.split(domain, ".", parts: 2)
    server = Map.fetch!(@servers, tld)
    host = server[:host]
    prefix = server[:prefix] || ""
    with {:ok, socket} <- :gen_tcp.connect(host, 43, [:binary, active: false]),
         :ok <- :gen_tcp.send(socket, "#{prefix}#{domain}\r\n"),
         do: {:ok, recv(socket)}
  end

  defp recv(socket, acc \\ "") do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> recv(socket, acc <> data)
      {:error, :closed} -> acc
    end
  end
end
