defmodule Clairvoyant.Application do
  @moduledoc """
  OTP entry point. Only matters for the Burrito-wrapped standalone binary —
  `mix run`, `mix test`, and the `clairvoyant` escript all call
  `Clairvoyant.CLI.main/1` directly and never boot this application.
  """

  use Application

  @impl true
  def start(_type, _args) do
    if Burrito.Util.running_standalone?() do
      Clairvoyant.CLI.main(Burrito.Util.Args.argv())
      System.halt(0)
    end

    Supervisor.start_link([], strategy: :one_for_one, name: Clairvoyant.Supervisor)
  end
end
