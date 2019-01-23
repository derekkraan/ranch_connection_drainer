defmodule RanchConnectionDrainer.MixProject do
  use Mix.Project

  def project do
    [
      app: :ranch_connection_drainer,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      source_url: "https://github.com/derekkraan/ranch_connection_drainer"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ranch, "~> 1.6"},
      {:ex_doc, "~> 0.19", only: :dev}
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
