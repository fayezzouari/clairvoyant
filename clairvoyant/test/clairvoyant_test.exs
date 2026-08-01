defmodule ClairvoyantTest do
  use ExUnit.Case
  doctest Clairvoyant

  test "greets the world" do
    assert Clairvoyant.hello() == :world
  end
end
