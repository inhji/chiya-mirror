defmodule ChiyaWeb.Indie.Token do
  require Logger

  @supported_scopes Application.compile_env!(:chiya, [:indie, :supported_scopes])

  def verify(access_token, required_scope, own_hostname) do
    case ChiyaWeb.Indie.Auth.verify_token(access_token) do
      {:ok, %{status: 200, body: body}} ->
        verify_token_response(body, required_scope, own_hostname)

      {:ok, %{status: status}} ->
        {:error, :insufficient_scope, status}

      {:error, %{code: code}} ->
        Logger.error("Token endpoint responded with unexpected code: #{inspect(code)}")
        {:error, :insufficient_scope, code}

      {:error, %{reason: reason}} ->
        Logger.error("Could not reach token endpoint: #{inspect(reason)}")
        {:error, :insufficient_scope, reason}

      error ->
        Logger.error("Unexpected error: #{inspect(error)}")
        {:error, :insufficient_scope, "Internal Server Error"}
    end
  end

  defp verify_token_response(
         %{
           me: host_uri,
           scope: scope,
           client_id: client_id,
           issued_at: _issued_at,
           issued_by: _issued_by,
           nonce: _nonce
         },
         required_scope,
         own_hostname
       ) do
    Logger.info("Host-URI: '#{host_uri}'")
    Logger.info("ClientId: '#{client_id}'")
    Logger.info("Scopes: '#{scope}'")

    with :ok <- verify_hostname_match(host_uri, own_hostname),
         :ok <- verify_scope_support(scope, required_scope, @supported_scopes) do
      :ok
    else
      {:error, name, reason} ->
        Logger.error("Could not verify token response: #{reason}")
        {:error, name, reason}
    end
  end

  defp verify_hostname_match(host_uri, own_hostname) do
    hostnames_match? = get_hostname(host_uri) == own_hostname

    case hostnames_match? do
      true ->
        :ok

      _ ->
        Logger.warn("Hostnames do not match: Given #{host_uri}, Actual: #{own_hostname}")
        {:error, "verify_hostname_match", "hostname does not match"}
    end
  end

  defp get_hostname(host_uri) do
    host_uri |> URI.parse() |> Map.get(:host)
  end

  defp verify_scope_support(_scopes, nil, _supported_scopes), do: :ok

  defp verify_scope_support(scopes, required_scope, supported_scopes) do
    required = Enum.member?(supported_scopes, required_scope)
    requested = Enum.member?(String.split(scopes), required_scope)

    cond do
      required && requested ->
        :ok

      !required ->
        {:error, "verify_scope_support", "scope '#{required_scope}' is not supported"}

      !requested ->
        {:error, "verify_scope_support", "scope '#{required_scope}' was not requested"}
    end
  end
end
