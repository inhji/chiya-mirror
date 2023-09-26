defmodule Chiya.MixProject do
  use Mix.Project

  def project do
    [
      app: :chiya,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Chiya.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:cors_plug, "~> 3.0"},
      {:coverex, "~> 1.5", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:earmark, "~> 1.4"},
      {:ecto_autoslug_field, "~> 3.0"},
      {:ecto_sql, "~> 3.6"},
      {:finch, "~> 0.16"},
      {:floki, ">= 0.30.0", only: :test},
      {:flop, "~> 0.22.1"},
      {:flop_phoenix, "~> 0.22.0"},
      {:gettext, "~> 0.23"},
      {:jason, "~> 1.2"},
      {:oban, "~> 2.14"},
      {:phoenix, "~> 1.7.1"},
      {:phoenix_active_link, "~> 0.3.2"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_dashboard, "~> 0.8.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.19"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:slugger, "~> 0.3"},
      {:swoosh, "~> 1.11"},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:tesla, "~> 1.7"},
      {:tz, "~> 0.26.1"},
      {:waffle, "~> 1.1"},
      {:waffle_ecto, "~> 0.0.12"},
      {:yaml_front_matter, "~> 1.0.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "cmd --cd assets npm install"],
      "assets.build": ["tailwind default", "cmd --cd assets node build.js"],
      "assets.deploy": [
        "tailwind default --minify",
        "cmd --cd assets node build.js --deploy",
        "phx.digest"
      ]
    ]
  end
end
