defmodule BlueskyTest do
  use ExUnit.Case
  doctest Bluesky

  test "greets the world" do
    assert Bluesky.hello() == :world
  end
end
