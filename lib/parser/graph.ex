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

    @spec children(t(), name())::[name()]
    def children(%__MODULE__{} = graph, name) do
      Map.get(graph.edges, name, [])
    end
end
