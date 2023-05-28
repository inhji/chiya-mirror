defmodule ChiyaWeb.Indie.Auth do
  use Tesla
  require Logger

  @base_url Application.compile_env!(:chiya, [:indie, :token_endpoint])
  @user_agent Application.compile_env!(:chiya, [ChiyaWeb.Endpoint, :user_agent])

  def verify_token(token) do
    token
    |> client()
    |> get("")
  end

  defp client(token) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, @base_url},
      {Tesla.Middleware.JSON, [engine: Jason, engine_opts: [keys: :atoms]]},
      {Tesla.Middleware.Headers,
       [
         {"User-Agent", @user_agent},
         {"Authorization", "Bearer #{token}"},
         {"Accept", "application/json"}
       ]}
    ])
  end
end
