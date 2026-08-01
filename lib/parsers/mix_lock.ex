defmodule Clairvoyant.Parsers.MixLock do
  @moduledoc "Parses Elixir/Hex `mix.lock` files."

  @behaviour Clairvoyant.Parser

  alias Clairvoyant.Graph
  alias Clairvoyant.Parsers.ElixirTerm

  @impl true
  def detect?(filename), do: filename == "mix.lock"

  @impl true
  def parse(path) do
    with {:ok, content} <- File.read(path),
         {:ok, lock} <- ElixirTerm.decode(content) do
      {:ok, build_graph(lock)}
    else
      {:error, :enoent} -> {:error, "file not found: #{path}"}
      {:error, reason} -> {:error, "failed to parse #{path}: #{reason}"}
    end
  end

  defp build_graph(lock) when is_map(lock) do
    names = lock |> Map.keys() |> Enum.map(&to_string/1) |> MapSet.new()

    graph =
      Enum.reduce(lock, Graph.new(), fn {name, entry}, graph ->
        Graph.add_node(graph, to_string(name), entry_version(entry))
      end)

    Enum.reduce(lock, graph, fn {name, entry}, graph ->
      Enum.reduce(entry_deps(entry), graph, fn dep_name, graph ->
        if MapSet.member?(names, dep_name) do
          Graph.add_edge(graph, to_string(name), dep_name)
        else
          graph
        end
      end)
    end)
  end

  defp build_graph(_other), do: Graph.new()

  defp entry_version({:hex, _name, version, _outer_checksum, _managers, _deps, _repo, _checksum}),
    do: version

  defp entry_version({:git, _url, ref, _opts}), do: String.slice(to_string(ref), 0, 7)
  defp entry_version({:path, path}), do: to_string(path)
  defp entry_version(_other), do: "unknown"

  defp entry_deps({:hex, _name, _version, _outer_checksum, _managers, deps, _repo, _checksum}) do
    Enum.map(deps, fn {dep_name, _requirement, _opts} -> to_string(dep_name) end)
  end

  defp entry_deps(_other), do: []
end
