defmodule QrPushTest do
  use ExUnit.Case

  test "hello" do
    assert "foo" == :gleam@string.lowercase("Foo")
    assert nil == :gleam@io.println("hello")
  end

  test "send_message_to_follower_test" do
    :ok = :qr_push@web_test.send_message_to_follower_test()
  end

  test "follower_fetch_message_test" do
    :ok = :qr_push@web_test.follower_fetch_message_test()
  end
end
