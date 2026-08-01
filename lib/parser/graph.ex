defmodule Clairvoyant.Graph do
  defstruct nodes: [], edges: []
  @type name: String.t()
  @type t :: %__MODULE__{
          nodes: [name()=>%{version: String.t()}],
          edges: [{name()=>[name()]}]
        }
  @spec new()::t()
  def new() do:  %__MODULE__{}

  @spec add_node(t(), name(), String.t())::t()
  def add_node(%__MODULE__{nodes: nodes} = graph, name, version) do
    %{graph | nodes: Map.put(nodes, name, %{version: version})}
  end

  @spec add_edge(t(), name(), name())::t()
  def add_edge(%__MODULE__{} =graph, from, to) do
    children = Map.get(graph.edges, from, [])
    if to in children do
      graph
    else
      %{graph | edges: Map.put(graph.edges, from, [to | children])}
    end
  end

  @spec children(t(), name())::[name()]
  def children(%__MODULE__{} = graph, name) do
    Map.get(graph.edges, name, [])
  end

  @spec parents(t(), name())::[name()]
  def parents(%__MODULE__{} = graph, name) do
    for {parent, children} <- graph.edges, name in children, do: parent
  end

  @spec roots(t())::[name()]
  def roots(%__MODULE__{} = graph) do
    all_children = graph.edges |> Map.values() |> List.flatten() |> MapSet.new()
    graph.nodes
    |> Map.keys()
    |> Enum.filter(fn node -> not MapSet.member?(all_children, node) end)
    |> Enum.sort()
  end

  @spec version(t(), name())::String.t() | nil
  def version(%__MODULE__{} = graph, name) do
    case Map.get(graph.nodes, name) do
      %{version: version} -> version
      nil -> nil
    end
  end
end
