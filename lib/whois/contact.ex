defmodule Whois.Contact do
  @moduledoc """
  Contact information listed in a WHOIS record.
  """
  defstruct [:name, :organization, :street, :city, :state, :zip, :country, :phone, :fax, :email]

  @type t :: %__MODULE__{
          name: String.t() | nil,
          organization: String.t() | nil,
          street: String.t() | nil,
          city: String.t() | nil,
          state: String.t() | nil,
          zip: String.t() | nil,
          country: String.t() | nil,
          phone: String.t() | nil,
          fax: String.t() | nil,
          email: String.t() | nil
        }
end
