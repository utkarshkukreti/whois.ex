defmodule Whois.Record do
  defstruct [:domain, :raw]

  def parse(domain, raw) do
    %Whois.Record{domain: domain, raw: raw}
  end
end
