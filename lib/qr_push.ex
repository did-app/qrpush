defmodule QrPush do
  def start_mailbox(opts) do
    id = GenServer.call(QrPush.Counter, {:assign})

    {:ok, redirect} = Keyword.fetch(opts, :redirect)

    {:ok, _pid} =
      DynamicSupervisor.start_child(QrPush.MailboxSupervisor, %{
        id: :no_op,
        start: {QrPush.Mailbox, :start_link, [id, redirect]},
        restart: :temporary
      })

    {:ok, id}
    # Need The id before starting to give it to the name field
  end

  # When is integer
  def follow_mailbox(id, cursor) do
    case :global.whereis_name({QrPush.Mailbox, id}) do
      pid when is_pid(pid) ->
        :ok = GenServer.call(pid, {:follow, self(), cursor})
        {:ok, :ref}

      :undefined ->
        {:error, :no_mailbox_process}
    end
  end
end
