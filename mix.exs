defmodule LogMon.MixProject do
  use Mix.Project

  def project do
    [
      app: :log_mon,
      version: "0.1.1",
      elixir: "~> 1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "LogMon",
      source_url: "https://github.com/NerdAlert58/log_mon",
      license: []
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp description() do
    "LogMon is a poc doubling as a log monitor, mainly so I can create a package."
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "log_mon",
      # These are the default files included in the package
      files: ~w(lib mix.exs README*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/NerdAlert58/log_mon"}
    ]
  end
end
