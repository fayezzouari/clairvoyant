defmodule Depviz.Parser do
  @moduledoc """
  Behaviour every lockfile format parser implements.
  """

  @callback detect?(filename :: String.t()) :: boolean()
  @callback parse(path :: String.t()) :: {:ok, Depviz.Graph.t()} | {:error, String.t()}

  @parsers [Depviz.Parsers.MixLock]

  @doc "Pick the right parser module for a given file path, by filename."
  @spec for_file(String.t()) :: {:ok, module()} | {:error, String.t()}
  def for_file(path) do
    basename = Path.basename(path)

    case Enum.find(@parsers, fn mod -> mod.detect?(basename) end) do
      nil -> {:error, "no parser registered for #{basename}"}
      mod -> {:ok, mod}
    end
  end
end
