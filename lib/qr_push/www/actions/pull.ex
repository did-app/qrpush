defmodule QrPush.WWW.Actions.Pull do
  use Raxx.Server
  require OK

  alias QrPush.Error

  # Creating the address and secret before starting polling allows the QR code to be showed instantly once connected
  # Also for Kno the QR code can stay open as long as it wan't create the checkin once the screen is showed
  @sse_mime_type ServerSentEvent.mime_type()
  def handle_head(request, state) do
    case Raxx.get_header(request, "last-event-id") do
      "Done" ->
        response(:no_content)

      nil ->
        OK.try do
          %{redirect: redirect} <- fetch_params(request)
        after
          {:ok, %{pull_token: pull_token, push_token: push_token}} =
            QrPush.Transmission.start_mailbox(redirect)

          {:ok, _ref} = QrPush.Transmission.follow_mailbox(pull_token)

          Process.send_after(self(), :ping, 10_000)

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
        rescue
          error ->
            event = %{type: "qrpu.sh/error", error: Error.to_data(error)}

            response(:ok)
            |> set_body(ServerSentEvent.serialize(Jason.encode!(event), id: "Done"))
        end

      pull_token ->
        OK.try do
          _ <- QrPush.Transmission.follow_mailbox(pull_token)
        after
          Process.send_after(self(), :ping, 10_000)
        rescue
          error ->
            event = %{type: "qrpu.sh/error", error: Error.to_data(error)}

            response(:ok)
            |> set_body(ServerSentEvent.serialize(Jason.encode!(event), id: "Done"))
        end
    end
  end

  def handle_info(:ping, state) do
    event = %ServerSentEvent{comments: ["ping"]}
    serialized = ServerSentEvent.serialize(event)

    Process.send_after(self(), :ping, 10_000)

    {[Raxx.data(serialized)], state}
  end

  def handle_info(m, state) do
    part = Raxx.data(ServerSentEvent.serialize(m, id: "Done"))
    {[part], state}
  end

  defp fetch_params(request) do
    query = Raxx.get_query(request)

    case Map.get(query, "redirect") do
      nil ->
        {:error, Error.invalid_request("'target query param is required to start mailbox'")}

      redirect ->
        {:ok, %{redirect: redirect}}
    end
  end
end
