defmodule Clairvoyant.Parsers.MixLockTest do
  use ExUnit.Case, async: true

  alias Clairvoyant.Graph
  alias Clairvoyant.Parsers.MixLock

  @fixture "test/fixtures/mix.lock"

  test "detect?/1 matches mix.lock by filename" do
    assert MixLock.detect?("mix.lock")
    refute MixLock.detect?("poetry.lock")
  end

  test "parses packages, versions and dependency edges" do
    assert {:ok, %Graph{} = graph} = MixLock.parse(@fixture)

    assert Graph.version(graph, "jason") == "1.4.5"
    assert Graph.version(graph, "phoenix") == "1.7.14"
    assert Enum.sort(Graph.children(graph, "phoenix")) == ["jason", "plug"]
  end

  test "handles non-hex (git) entries without crashing" do
    assert {:ok, %Graph{} = graph} = MixLock.parse(@fixture)
    assert Graph.version(graph, "my_app") == "abcdef1"
  end

  test "skips edges to dependencies absent from the lockfile" do
    assert {:ok, %Graph{} = graph} = MixLock.parse(@fixture)
    refute "decimal" in Graph.children(graph, "jason")
  end

  test "returns an error for a missing file" do
    assert {:error, reason} = MixLock.parse("test/fixtures/does_not_exist.lock")
    assert reason =~ "not found"
  end
end
