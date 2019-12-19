defmodule QrPush.WWW.Actions.Pull do
  use Raxx.Server

  # Creating the address and secret before starting polling allows the QR code to be showed instantly once connected
  # Also for Kno the QR code can stay open as long as it wan't create the checkin once the screen is showed
  @sse_mime_type ServerSentEvent.mime_type()
  def handle_head(request, state) do
    case Raxx.get_header(request, "last-event-id") do
      nil ->
        %{"redirect" => redirect} = Raxx.get_query(request)

        {:ok, %{pull_token: pull_token, push_token: push_token}} =
          QrPush.start_mailbox(redirect)
          |> IO.inspect()

        # TODO handle down
        {:ok, _ref} = QrPush.follow_mailbox(pull_token)

        url = "#{request.scheme}://#{request.authority}/#{push_token}"

        svg =
          url
          |> EQRCode.encode()
          |> EQRCode.svg()

        data_url = "data:image/svg+xml;base64," <> Base.encode64(svg)

        response_head =
          response(:ok)
          |> set_header("content-type", @sse_mime_type)
          |> set_header("access-control-allow-origin", "*")
          |> set_body(true)

        event = %{type: "qrpu.sh/init", url: url, data_url: data_url}
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
