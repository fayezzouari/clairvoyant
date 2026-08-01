defmodule Clairvoyant.Parsers.UvLock do
  @moduledoc "Parses Python/uv `uv.lock` files."

  @behaviour Clairvoyant.Parser

  alias Clairvoyant.Graph

  @impl true
  def detect?(filename), do: filename == "uv.lock"

  @impl true
  def parse(path) do
    case Toml.decode_file(path) do
      {:ok, %{"package" => packages}} -> {:ok, build_graph(packages)}
      {:ok, _no_packages} -> {:ok, Graph.new()}
      {:error, reason} -> {:error, "failed to parse #{path}: #{format_reason(reason)}"}
    end
  end

  defp build_graph(packages) do
    names = MapSet.new(packages, & &1["name"])

    graph =
      Enum.reduce(packages, Graph.new(), fn pkg, graph ->
        Graph.add_node(graph, pkg["name"], pkg["version"])
      end)

    Enum.reduce(packages, graph, fn pkg, graph ->
      pkg
      |> Map.get("dependencies", [])
      |> Enum.reduce(graph, fn dep, graph ->
        case dep["name"] do
          dep_name when is_binary(dep_name) ->
            if MapSet.member?(names, dep_name) do
              Graph.add_edge(graph, pkg["name"], dep_name)
            else
              graph
            end

          _other ->
            graph
        end
      end)
    end)
  end

  defp format_reason({:invalid_toml, message}), do: message
  defp format_reason(reason) when is_binary(reason), do: reason
  defp format_reason(reason), do: inspect(reason)
end
