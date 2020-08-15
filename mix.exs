defmodule RanchConnectionDrainer.MixProject do
  use Mix.Project

  def project do
    [
      app: :ranch_connection_drainer,
      version: "0.2.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      source_url: "https://github.com/derekkraan/ranch_connection_drainer"
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ranch, "~> 1.6"},
      {:ex_doc, "~> 0.19", only: :dev},
      {:plug_cowboy, "~> 2.0", only: :test},
      {:mockery, "~> 2.3", runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp package() do
    [
      description: "Connection draining for Ranch listeners (Cowboy / Plug / Phoenix)",
      licenses: ["MIT"],
      maintainers: ["Derek Kraan"],
      links: %{github: "https://github.com/derekkraan/ranch_connection_drainer"}
    ]
  end
end
