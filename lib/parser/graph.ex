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
end
