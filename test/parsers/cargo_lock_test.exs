defmodule Clairvoyant.Parsers.CargoLockTest do
  use ExUnit.Case, async: true

  alias Clairvoyant.Graph
  alias Clairvoyant.Parsers.CargoLock

  @fixture "test/fixtures/Cargo.lock"

  test "detect?/1 matches Cargo.lock case-insensitively" do
    assert CargoLock.detect?("Cargo.lock")
    assert CargoLock.detect?("cargo.lock")
    refute CargoLock.detect?("mix.lock")
  end

  test "parses packages, versions and dependency edges" do
    assert {:ok, %Graph{} = graph} = CargoLock.parse(@fixture)

    assert Graph.version(graph, "serde") == "1.0.197"
    assert Enum.sort(Graph.children(graph, "app")) == ["log", "serde"]
    assert Graph.children(graph, "serde") == ["serde_derive"]
  end

  test "resolves 'name version' dependency entries to just the name" do
    assert {:ok, %Graph{} = graph} = CargoLock.parse(@fixture)
    assert "log" in Graph.children(graph, "app")
  end

  test "returns an error for a missing file" do
    assert {:error, reason} = CargoLock.parse("test/fixtures/does_not_exist.lock")
    assert reason =~ "failed to parse"
  end
end
