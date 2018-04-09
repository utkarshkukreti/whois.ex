defmodule Whois.Server do
  defstruct [:host]

  @type t :: %__MODULE__{host: String.t()}

  @all File.read!(Application.app_dir(:whois, "priv/tld.csv"))
       |> String.trim()
       |> String.split("\n")
       |> Enum.map(fn line ->
         [tld, host] = String.split(line, ",")
         {tld, %{__struct__: __MODULE__, host: host}}
       end)
       |> Map.new()

  @spec all :: map
  def all, do: @all

  @spec for(String.t()) :: {:ok, t} | :error
  def for(domain) do
    [_, tld] = String.split(domain, ".", parts: 2)
    Map.fetch(@all, tld)
  end
end
