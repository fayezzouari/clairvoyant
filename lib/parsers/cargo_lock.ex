defmodule Clairvoyant.Parsers.CargoLock do
  @moduledoc "Parses Rust/Cargo `Cargo.lock` files."

  @behaviour Clairvoyant.Parser

  alias Clairvoyant.Graph

  @impl true
  def detect?(filename), do: String.downcase(filename) == "cargo.lock"

  @impl true
  def parse(path) do
    case Toml.decode_file(path) do
      {:ok, %{"package" => packages}} -> {:ok, build_graph(packages)}
      {:ok, _no_packages} -> {:ok, Graph.new()}
      {:error, reason} -> {:error, "failed to parse #{path}: #{format_reason(reason)}"}
    end
  end

  defp build_graph(packages) do
    by_name = MapSet.new(packages, & &1["name"])

    graph =
      Enum.reduce(packages, Graph.new(), fn pkg, graph ->
        Graph.add_node(graph, pkg["name"], pkg["version"])
      end)

    Enum.reduce(packages, graph, fn pkg, graph ->
      pkg["dependencies"]
      |> List.wrap()
      |> Enum.reduce(graph, fn dep_spec, graph ->
        case resolve_dependency(dep_spec, by_name) do
          nil -> graph
          dep_name -> Graph.add_edge(graph, pkg["name"], dep_name)
        end
      end)
    end)
  end

  # A dependency entry in Cargo.lock is either just "name", or
  # "name version" when the same crate appears at multiple versions in the
  # tree — either way, the crate name is the first whitespace-separated
  # token.
  defp resolve_dependency(dep_spec, by_name) do
    name = dep_spec |> String.split(" ", parts: 2) |> List.first()
    if MapSet.member?(by_name, name), do: name
  end

  defp format_reason({:invalid_toml, message}), do: message
  defp format_reason(reason) when is_binary(reason), do: reason
  defp format_reason(reason), do: inspect(reason)
end
