defmodule OuterfacesTest do
  use ExUnit.Case
  doctest Outerfaces

  test "greets the world" do
    assert Outerfaces.hello() == :world
  end
end
