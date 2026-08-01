defmodule Clairvoyant.Parsers.PoetryLock do
  @moduledoc "Parses Python/Poetry `poetry.lock` files."

  @behaviour Clairvoyant.Parser

  alias Clairvoyant.Graph

  @impl true
  def detect?(filename), do: filename == "poetry.lock"

  @impl true
  def parse(path) do
    case Toml.decode_file(path) do
      {:ok, %{"package" => packages}} -> {:ok, build_graph(packages)}
      {:ok, _no_packages} -> {:ok, Graph.new()}
      {:error, reason} -> {:error, "failed to parse #{path}: #{format_reason(reason)}"}
    end
  end

  defp build_graph(packages) do
    by_normalized_name =
      Map.new(packages, fn pkg -> {normalize(pkg["name"]), pkg["name"]} end)

    graph =
      Enum.reduce(packages, Graph.new(), fn pkg, graph ->
        Graph.add_node(graph, pkg["name"], pkg["version"])
      end)

    Enum.reduce(packages, graph, fn pkg, graph ->
      pkg
      |> Map.get("dependencies", %{})
      |> Map.keys()
      |> Enum.reduce(graph, fn dep_name, graph ->
        case Map.get(by_normalized_name, normalize(dep_name)) do
          nil -> graph
          real_name -> Graph.add_edge(graph, pkg["name"], real_name)
        end
      end)
    end)
  end

  # Poetry lets a dependency's declared name and its lockfile package name
  # differ in case and separator (`-`, `_`, `.`) — e.g. `PyYAML` vs
  # `pyyaml`, or `typing-extensions` vs `typing_extensions`. Normalize both
  # sides before matching them up.
  defp normalize(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[-_.]+/, "-")
  end

  defp format_reason({:invalid_toml, message}), do: message
  defp format_reason(reason) when is_binary(reason), do: reason
  defp format_reason(reason), do: inspect(reason)
end
