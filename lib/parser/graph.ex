defmodule Clairvoyant.Graph do
  defstruct nodes: [], edges: []
  @type name: String.t()
  @type t :: %__MODULE__{
          nodes: [name()=>%{version: String.t()}],
          edges: [{name()=>[name()]}]
        }
end
