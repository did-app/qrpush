defmodule QrPush.WWW.Actions.Push do
  use Raxx.SimpleServer

  def handle_request(request, state) do
    ["push", token] = request.path

    {id, ""} = Integer.parse(token)
    IO.inspect(id)

    case :global.whereis_name({QrPush.Mailbox, id}) do
      pid when is_pid(pid) ->
        :ok = GenServer.call(pid, {:push, request.body})
        response(:ok)

      :undefined ->
        {:error, :no_mailbox_process}
    end
  end
end
