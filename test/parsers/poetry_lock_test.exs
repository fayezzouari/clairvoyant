defmodule Clairvoyant.Parsers.PoetryLockTest do
  use ExUnit.Case, async: true

  alias Clairvoyant.Graph
  alias Clairvoyant.Parsers.PoetryLock

  @fixture "test/fixtures/poetry.lock"

  test "detect?/1 matches poetry.lock by filename" do
    assert PoetryLock.detect?("poetry.lock")
    refute PoetryLock.detect?("uv.lock")
  end

  test "parses packages, versions and dependency edges" do
    assert {:ok, %Graph{} = graph} = PoetryLock.parse(@fixture)

    assert Graph.version(graph, "requests") == "2.31.0"
    assert Enum.sort(Graph.children(graph, "requests")) == ["certifi", "idna"]
  end

  test "matches dependency table keys case-insensitively (e.g. quoted keys)" do
    assert {:ok, %Graph{} = graph} = PoetryLock.parse(@fixture)
    assert "idna" in Graph.children(graph, "requests")
  end

  test "returns an error for a missing file" do
    assert {:error, reason} = PoetryLock.parse("test/fixtures/does_not_exist.lock")
    assert reason =~ "failed to parse"
  end
end
