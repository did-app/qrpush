defmodule QrPush.Transmission.MailboxTest do
  use ExUnit.Case

  alias QrPush.Transmission.Mailbox

  # Can put self as the target to test both sides
  test "can't follow with invalid token" do
    {state, _tokens} = Mailbox.setup("anything")
    response = Mailbox.handle_call({:follow, self(), "badsecret"}, :from, state)
    assert {:reply, {:error, error}, ^state} = response
    assert %{code: :operation_denied} = error
  end

  test "mailbox starts timeout if follower process stops" do
    {state, tokens} = Mailbox.setup("anything")
    {:ok, {id, pull_secret}} = QrPush.Transmission.decode_token(tokens.pull_token)
    pid = spawn(fn -> :done end)
    {:reply, _, state} = Mailbox.handle_call({:follow, pid, pull_secret}, :from, state)
    assert_receive down_message
    response = Mailbox.handle_info(down_message, state)
    assert {:noreply, ^state, 300_000} = response
    IO.inspect(response)
    flunk()
  end

  # Down message from some other pid is ignored 

  test "can't redirect with invalid token" do
    {state, _tokens} = Mailbox.setup("anything")
    response = Mailbox.handle_call({:redirect, "badsecret"}, :from, state)
    assert {:reply, {:error, error}, ^state} = response
    assert %{code: :operation_denied} = error
  end

  test "can't push with invalid token" do
    {state, _tokens} = Mailbox.setup("anything")
    response = Mailbox.handle_call({:push, "badsecret", "stuff"}, :from, state)
    assert {:reply, {:error, error}, ^state} = response
    assert %{code: :operation_denied} = error
  end
end
