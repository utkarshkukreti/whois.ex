defmodule Whois.Server do
  @moduledoc """
  A server we can direct WHOIS requests to.
  """
  defstruct [:host]

  @type t :: %__MODULE__{host: String.t()}

  @overrides Map.new(
               %{"africa" => "whois.nic.africa"},
               fn {tld, host} -> {tld, %{__struct__: __MODULE__, host: host}} end
             )

  @all File.read!(Application.app_dir(:whois, "priv/tld.csv"))
       |> String.trim()
       |> String.split("\n")
       |> Enum.map(fn line ->
         [tld, host] = String.split(line, ",")
         {tld, %{__struct__: __MODULE__, host: host}}
       end)
       |> Map.new()
       |> Map.merge(@overrides)

  @doc """
  A map from TLD to the WHOIS server we'll query by default.
  """
  @spec all :: map
  def all, do: @all

  @spec for(String.t()) :: {:ok, t} | {:error, :unsupported_tld}
  def for(domain) do
    tld =
      domain
      |> String.split(".")
      |> List.last()

    case @all[tld] do
      nil -> {:error, :unsupported_tld}
      server -> {:ok, server}
    end
  end
end
