defmodule Outerfaces.MixProject do
  use Mix.Project

  def project do
    [
      app: :outerfaces,
      version: "0.2.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Portable, Dynamic Web Applications",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:ex_doc, "~> 0.37"}
    ]
  end

  defp package do
    [
      maintainers: ["Aligned To Development - development@alignedto.dev"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/outerfaces/outerfaces_ex_core"}
    ]
  end
end
