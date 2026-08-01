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

end
