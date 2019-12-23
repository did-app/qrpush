defmodule QrPush.Transmission do
  require OK

  alias QrPush.Error

  def start_mailbox(redirect) do
    start_result =
      DynamicSupervisor.start_child(QrPush.Transmission.MailboxSupervisor, %{
        id: :no_op,
        start: {QrPush.Transmission.Mailbox, :start_link, [redirect]},
        restart: :temporary
      })

    case start_result do
      {:ok, pid, tokens} ->
        {:ok, tokens}

      {:error, reason} ->
        {:error, reason}
    end

    # Need The id before starting to give it to the name field
  end

  def follow_mailbox(pull_token) do
    OK.for do
      {id, pull_secret} <- decode_token(pull_token)
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
    case :global.whereis_name({QrPush.Transmission.Mailbox, id}) do
      pid when is_pid(pid) ->
        {:ok, pid}

      :undefined ->
        {:error, :gone}
    end
  end

  def decode_token(token) do
    case Base.decode32(token) do
      {:ok, <<id::32, secret::binary>>} ->
        {:ok, {id, secret}}

      _ ->
        {:error, Error.invalid_request("Invalid token")}
    end
  end
end
