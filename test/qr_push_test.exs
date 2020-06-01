defmodule QrPushTest do
  use ExUnit.Case

  test "hello" do
    assert "foo" == :gleam@string.lowercase("Foo")
    assert nil == :gleam@io.println("hello")
  end
end
