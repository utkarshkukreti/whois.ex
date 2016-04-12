defmodule Whois.Server do
  alias __MODULE__

  defstruct [:host, :prefix]

  @type t :: %__MODULE__{host: char_list,
                         prefix: String.t}

  @spec all :: map
  def all do
    %{
      "com" => %Server{host: 'whois.verisign-grs.com', prefix: "="},
      "net" => %Server{host: 'whois.verisign-grs.com'},
      "org" => %Server{host: 'whois.pir.org'}
    }
  end

  @spec for(String.t) :: {:ok, t} | :error
  def for(domain) do
    [_, tld] = String.split(domain, ".", parts: 2)
    Map.fetch(all, tld)
  end
end
