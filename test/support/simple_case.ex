defmodule Chiya.SimpleCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint ChiyaWeb.Endpoint

      use ChiyaWeb, :verified_routes
    end
  end
end
