defmodule Clairvoyant.Parsers.UvLockTest do
  use ExUnit.Case, async: true

  alias Clairvoyant.Graph
  alias Clairvoyant.Parsers.UvLock

  @fixture "test/fixtures/uv.lock"

  test "detect?/1 matches uv.lock by filename" do
    assert UvLock.detect?("uv.lock")
    refute UvLock.detect?("poetry.lock")
  end

  test "parses packages, versions and dependency edges" do
    assert {:ok, %Graph{} = graph} = UvLock.parse(@fixture)

    assert Graph.version(graph, "requests") == "2.31.0"
    assert Graph.children(graph, "app") == ["requests"]
    assert Enum.sort(Graph.children(graph, "requests")) == ["certifi", "idna"]
  end

  test "packages without a dependencies key parse cleanly" do
    assert {:ok, %Graph{} = graph} = UvLock.parse(@fixture)
    assert Graph.children(graph, "certifi") == []
  end

  test "returns an error for a missing file" do
    assert {:error, reason} = UvLock.parse("test/fixtures/does_not_exist.lock")
    assert reason =~ "failed to parse"
  end
end
