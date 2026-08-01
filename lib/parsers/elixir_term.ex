defmodule Clairvoyant.Parsers.ElixirTerm do
  @moduledoc """
  Decodes a string of Elixir source into a plain term, without executing any
  code. Only literals (maps, tuples, lists, atoms, strings, numbers,
  booleans, nil) are supported — anything else (function calls, variables,
  module attributes, ...) is rejected. This is what makes it safe to use on
  a `mix.lock` file, which is untrusted input.
  """

  @spec decode(String.t()) :: {:ok, term()} | {:error, String.t()}
  def decode(source) do
    case Code.string_to_quoted(source) do
      {:ok, ast} -> literal(ast)
      {:error, {_meta, message, token}} -> {:error, "#{message}#{token}"}
    end
  end

  defp literal({:%{}, _meta, pairs}) do
    with {:ok, pairs} <- literal_list(pairs) do
      {:ok, Map.new(pairs)}
    end
  end

  defp literal({:{}, _meta, elems}), do: literal_tuple(elems)
  defp literal({a, b}), do: literal_tuple([a, b])
  defp literal(list) when is_list(list), do: literal_list(list)

  defp literal(v) when is_binary(v) or is_number(v) or is_atom(v), do: {:ok, v}

  defp literal(other), do: {:error, "unsupported expression: #{inspect(other)}"}

  defp literal_tuple(elems) do
    with {:ok, values} <- literal_list(elems) do
      {:ok, List.to_tuple(values)}
    end
  end

  defp literal_list(list) do
    Enum.reduce_while(list, {:ok, []}, fn item, {:ok, acc} ->
      case literal_item(item) do
        {:ok, value} -> {:cont, {:ok, [value | acc]}}
        {:error, _} = error -> {:halt, error}
      end
    end)
    |> case do
      {:ok, acc} -> {:ok, Enum.reverse(acc)}
      error -> error
    end
  end

  defp literal_item({key, value}) do
    with {:ok, k} <- literal(key),
         {:ok, v} <- literal(value) do
      {:ok, {k, v}}
    end
  end

  defp literal_item(other), do: literal(other)
end
