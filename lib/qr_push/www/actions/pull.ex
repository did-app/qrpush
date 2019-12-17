defmodule QrPush.WWW.Actions.Pull do
  use Raxx.Server

  @sse_mime_type ServerSentEvent.mime_type()
  def handle_head(request, state) do
    case Raxx.get_header(request, "last-event-id") do
      nil ->
        %{"redirect" => redirect} = Raxx.get_query(request)

        {:ok, %{pull_token: pull_token, push_token: push_token}} = QrPush.start_mailbox(redirect)

        {:ok, ref} = QrPush.follow_mailbox(pull_token)

        url = "#{request.scheme}://#{request.authority}/#{push_token}"

        response_head =
          response(:ok)
          |> set_header("content-type", @sse_mime_type)
          |> set_header("access-control-allow-origin", "*")
          |> set_body(true)

        event = %{type: "qrpu.sh/init", url: url}
        {:ok, data} = Jason.encode(event)
        part = Raxx.data(ServerSentEvent.serialize(data, id: "#{pull_token}"))
        {[response_head, part], state}
    end
  end

  def handle_info(m, state) do
    IO.inspect(m)
    part = Raxx.data(ServerSentEvent.serialize(m, id: "Done"))
    {[part], state}
  end
end
