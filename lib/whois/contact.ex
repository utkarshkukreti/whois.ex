defmodule Whois.Contact do
  defstruct [:name, :organization, :street, :city, :state, :zip, :country, :phone, :fax, :email]

  @type t :: %__MODULE__{
          name: String.t(),
          organization: String.t(),
          street: String.t(),
          city: String.t(),
          state: String.t(),
          zip: String.t(),
          country: String.t(),
          phone: String.t(),
          fax: String.t(),
          email: String.t()
        }
end
