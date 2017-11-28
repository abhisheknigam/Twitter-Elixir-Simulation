defmodule TweeterTest do
  use ExUnit.Case
  doctest Tweeter

  test "greets the world" do
    Tweeter.main([])
    assert Tweeter.hello() == :world
  end
end
