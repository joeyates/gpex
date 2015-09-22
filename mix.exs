defmodule Gpex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :gpex,
      version: "0.0.1",
      elixir: "~> 1.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:expand, ">= 0.0.3"},
      {:sweet_xml, ">= 0.4.0"},
    ]
  end
end
