defmodule Mix.Tasks.Whois.Fetch do
  @moduledoc false

  def run(domains) do
    root = Path.expand("../fixtures/raw", __DIR__)
    File.mkdir_p!(root)

    for domain <- domains do
      {:ok, record} = Whois.lookup(domain)
      path = Path.join(root, domain)
      File.write!(path, record.raw)
      IO.puts("[✓] #{domain}: wrote #{byte_size(record.raw)} bytes to #{path}")
    end
  end
end
