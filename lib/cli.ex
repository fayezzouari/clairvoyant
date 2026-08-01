defmodule Clairvoyant.CLI do
  @moduledoc "Entry point for the depviz escript."

  def main(args) do
    {opts, positional, invalid} =
      OptionParser.parse(args,
        strict: [depth: :integer, only: :string, reverse: :string, help: :boolean],
        aliases: [h: :help]
      )

    cond do
      opts[:help] || positional == [] ->
        print_usage()

      invalid != [] ->
        Enum.each(invalid, fn {flag, _} -> IO.puts(:stderr, "unrecognized option: #{flag}") end)
        System.halt(1)

      true ->
        [path] = positional
        run(path, opts)
    end
  end

  defp run(path, opts) do
    with {:ok, parser} <- Clairvoyant.Parser.for_file(path),
         {:ok, graph} <- parser.parse(path) do
      render_opts =
        opts
        |> Keyword.take([:depth])
        |> add_direction(opts)

      Clairvoyant.Renderer.Tree.render(graph, render_opts)
    else
      {:error, reason} ->
        IO.puts(:stderr, "error: #{reason}")
        System.halt(1)
    end
  end

  defp add_direction(render_opts, opts) do
    cond do
      opts[:only] ->
        Keyword.put(render_opts, :roots, [opts[:only]])

      opts[:reverse] ->
        render_opts
        |> Keyword.put(:roots, [opts[:reverse]])
        |> Keyword.put(:direction, :backward)

      true ->
        render_opts
    end
  end

  defp print_usage do
    IO.puts("""
    depviz — visualize a project's dependency tree from its lockfile

    USAGE:
        depviz <lockfile> [options]

    OPTIONS:
        --depth N       limit tree depth
        --only PACKAGE  show only the subtree rooted at PACKAGE
        --reverse PACKAGE  show what depends on PACKAGE (walks ancestors)
        --help, -h      show this help

    EXAMPLES:
        depviz mix.lock
        depviz mix.lock --depth 2
        depviz mix.lock --only phoenix
        depviz mix.lock --reverse jason
    """)
  end
end
