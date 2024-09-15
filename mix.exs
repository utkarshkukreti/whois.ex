defmodule Whois.Mixfile do
  use Mix.Project

  @source_url "https://github.com/utkarshkukreti/whois.ex"

  @spec project() :: Keyword.t()
  def project do
    [
      app: :whois,
      version: "0.3.1",
      elixir: "~> 1.12",
      consolidate_protocols: Mix.env() != :test,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      test_coverage: [
        tool: ExCoveralls,
        ignore_modules: [~r/Mix.Tasks.Whois/]
      ],
      preferred_cli_env: [
        check: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        dialyzer: :dev
      ],
      docs: docs(),
      name: "Whois",
      description: "Pure Elixir WHOIS client and parser.",
      package: package(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        flags: [:error_handling, :unknown],
        # Error out when an ignore rule is no longer useful so we can remove it
        list_unused_filters: true
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  @spec application() :: Keyword.t()
  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.18", only: :dev},
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},
      {:date_time_parser, "~> 1.2"},
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18.0", only: [:dev, :test], runtime: false},
      {:patch, "~> 0.13.0", only: [:test]}
    ]
  end

  defp package do
    [
      maintainers: ["Utkarsh Kukreti", "Tyler Young"],
      licenses: ["MIT"],
      links: %{GitHub: @source_url},
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md", "priv/tld.csv"]
    ]
  end

  defp aliases do
    [
      check: [
        "clean",
        "deps.unlock --check-unused",
        "compile --warnings-as-errors",
        "test --warnings-as-errors",
        "format --check-formatted",
        "deps.unlock --check-unused",
        "check.dialyzer"
      ],
      "check.dialyzer": "cmd MIX_ENV=dev mix dialyzer"
    ]
  end

  defp docs do
    [
      extras: ["CHANGELOG.md", "README.md"],
      main: "readme",
      source_url: @source_url,
      formatters: ["html"]
    ]
  end
end
