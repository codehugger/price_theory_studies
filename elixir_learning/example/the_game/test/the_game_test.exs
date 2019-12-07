defmodule TheGameTest do
  use ExUnit.Case
  doctest TheGame

  test "greets the world" do
    assert TheGame.hello() == :world
  end
end
