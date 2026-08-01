defmodule Clairvoyant.MixProject do
    use Mix.Project

    def project do
        [
            app: :clairvoyant,
            version: "0.1.0",
            elixir: "~> 1.14",
            start_permanent: Mix.env() == :prod,
            deps: deps(),
            escript: [main_module: Clairvoyant.CLI]
        ]
    end

    def application do
        [
            extra_applications: [:logger]
        ]
    end

    def deps do
        [
            {:ex_doc, "~> 0.30", only: :dev, runtime: false},
            {:jason, "~> 1.4"},
            {:httpoison, "~> 2.1"},
            {:floki, "~> 0.34.0"},
            {:toml, "~> 0.7"}
        ]
    end

end
