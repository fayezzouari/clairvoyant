defmodule Clairvoyant.Renderer.Tree do
  @moduledoc "Prints a Graph as an ASCII tree, starting from one or more roots."

  alias Clairvoyant.Graph

  @spec render(Graph.t(), keyword()) :: :ok
  def render(%Graph{} = graph, opts \\ []) do
    max_depth = Keyword.get(opts, :depth, :infinity)
    roots = Keyword.get(opts, :roots, Graph.roots(graph))

    edges_fn =
      case Keyword.get(opts, :direction, :forward) do
        :forward -> &Graph.children/2
        :backward -> &Graph.parents/2
      end

    Enum.each(roots, fn root ->
      print_node(graph, root, "", true, max_depth, 0, MapSet.new(), edges_fn)
    end)
  end

  defp print_node(graph, name, prefix, is_last, max_depth, depth, seen, edges_fn) do
    version = Graph.version(graph, name)
    connector = if depth == 0, do: "", else: if(is_last, do: "└── ", else: "├── ")
    label = colorize(name, depth)

    IO.puts(prefix <> connector <> label <> dim(" #{version}"))

    cond do
      MapSet.member?(seen, name) ->
        :ok

      depth >= max_depth ->
        :ok

      true ->
        neighbors = edges_fn.(graph, name)
        child_prefix = prefix <> if depth == 0, do: "", else: if(is_last, do: "    ", else: "│   ")
        seen = MapSet.put(seen, name)

        neighbors
        |> Enum.with_index()
        |> Enum.each(fn {neighbor, idx} ->
          print_node(graph, neighbor, child_prefix, idx == length(neighbors) - 1, max_depth, depth + 1, seen, edges_fn)
        end)
    end
  end

  defp colorize(name, 0), do: IO.ANSI.bright() <> name <> IO.ANSI.reset()
  defp colorize(name, _depth), do: name

  defp dim(text), do: IO.ANSI.faint() <> text <> IO.ANSI.reset()
end
