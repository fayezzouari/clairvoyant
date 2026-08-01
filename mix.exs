defmodule Clairvoyant.MixProject do
    use Mix.Project

    def project do
        [
            app: :clairvoyant,
            version: "0.1.0",
            elixir: "~> 1.14",
            start_permanent: Mix.env() == :prod,
            deps: deps(),
            escript: [main_module: Clairvoyant.CLI],
            releases: releases()
        ]
    end

    defp releases do
        [
            clairvoyant: [
                steps: [:assemble, &Burrito.wrap/1],
                burrito: [
                    targets: [
                        macos_intel: [os: :darwin, cpu: :x86_64],
                        macos_arm: [os: :darwin, cpu: :aarch64],
                        linux: [os: :linux, cpu: :x86_64],
                        windows: [os: :windows, cpu: :x86_64]
                    ]
                ]
            ]
        ]
    end

    def application do
        [
            extra_applications: [:logger],
            mod: {Clairvoyant.Application, []}
        ]
    end

    def deps do
        [
            {:ex_doc, "~> 0.30", only: :dev, runtime: false},
            {:jason, "~> 1.4"},
            {:httpoison, "~> 2.1"},
            {:floki, "~> 0.34.0"},
            {:toml, "~> 0.7"},
            {:burrito, "~> 1.0"}
        ]
    end

end
