defmodule QrPush.WWW.Actions.Redirect do
  use Raxx.SimpleServer

  def handle_request(request = %{method: :GET}, _state) do
    [address] = request.path

    IO.inspect(address)
    {id, ""} = Integer.parse(address)

    case :global.whereis_name({QrPush.Mailbox, id}) do
      pid when is_pid(pid) ->
        {:ok, target} = GenServer.call(pid, {:redirect, address})

        url = "#{request.scheme}://#{request.authority}/push/#{id}"
        redirect(target <> "?qrpu.sh=#{url}")

      :undefined ->
        {:error, :no_mailbox_process}
    end
  end
end
