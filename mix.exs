defmodule Gpex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :gpex,
      version: "0.1.1",
      elixir: "~> 1.0",
      description: "Parse GPX files",
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [applications: [:logger, :saxy]]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:saxy, "~> 1.5"}
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/joeyates/gpex"
      },
      maintainers: ["Joe Yates"]
    }
  end
end
