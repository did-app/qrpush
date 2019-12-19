defmodule QrPush do
  require OK

  def start_mailbox(redirect) do
    OK.for do
      id <- QrPush.Sequence.assign_id()
      pull_secret = :crypto.strong_rand_bytes(16)
      push_secret = :crypto.strong_rand_bytes(6)
      # Need to keep sending pull token, might be easier encrypted
      pull_token = Base.encode32(<<id::32, pull_secret::binary>>)
      push_token = Base.encode32(<<id::32, push_secret::binary>>)

      _pid <-
        DynamicSupervisor.start_child(QrPush.MailboxSupervisor, %{
          id: :no_op,
          start:
            {QrPush.Mailbox, :start_link, [id, redirect, mask(pull_secret), mask(push_secret)]},
          restart: :temporary
        })
    after
      %{pull_token: pull_token, push_token: push_token}
    end

    # Need The id before starting to give it to the name field
  end

  def follow_mailbox(pull_token) do
    OK.for do
      <<id::32, pull_secret::binary>> <- Base.decode32(pull_token)
      pid <- whereis_mailbox(id)
    after
      # Cursor is just zero, need to put cursor in token
      :ok = GenServer.call(pid, {:follow, self(), pull_secret})
      # TODO ref
      {:ok, :ref}
    end
  end

  def redirect(push_token) do
    OK.for do
      {id, push_secret} <- decode_token(push_token)
      pid <- whereis_mailbox(id)
      target <- GenServer.call(pid, {:redirect, push_secret})
    after
      target
    end
  end

  def push(push_token, message) do
    OK.for do
      {id, push_secret} <- decode_token(push_token)
      pid <- whereis_mailbox(id)
      _ <- GenServer.call(pid, {:push, push_secret, message})
    after
      :ok
    end
  end

  defp whereis_mailbox(id) do
    case :global.whereis_name({QrPush.Mailbox, id}) do
      pid when is_pid(pid) ->
        {:ok, pid}

      :undefined ->
        {:error, :gone}
    end
  end

  defp mask(secret) do
    Base.encode32(:crypto.hash(:sha256, secret))
  end

  def decode_token(token) do
    case Base.decode32(token) do
      {:ok, <<id::32, secret::binary>>} ->
        {:ok, {id, secret}}

      _ ->
        {:error, :invalid_token}
    end
  end
end
