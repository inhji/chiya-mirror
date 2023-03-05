defmodule Chiya.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ChiyaWeb.Telemetry,
      # Start the Ecto repository
      Chiya.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Chiya.PubSub},
      # Start Finch
      {Finch, name: Chiya.Finch},
      # Start the Endpoint (http/https)
      ChiyaWeb.Endpoint
      # Start a worker by calling: Chiya.Worker.start_link(arg)
      # {Chiya.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chiya.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChiyaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
