defmodule QrPush.WWW.Actions.PullTest do
  use ExUnit.Case

  alias QrPush.WWW.Actions.Pull

  # TODO handle pings
  # TODO handle revolved message from a new connect
  # TODO handle down of mailbox

  test "Cannot start a stream without redirect target" do
    request = Raxx.request(:GET, "/pull")
    response = Pull.handle_head(request, :state)
    assert response.status == 200
    assert {:ok, {%{id: "Done", lines: [json]}, ""}} = ServerSentEvent.parse(response.body)
    assert {:ok, %{"type" => _, "error" => error}} = Jason.decode(json)
    assert error["code"] == "invalid_request"
  end

  test "cannot reconnect with an invalid last-event-id" do
    request =
      Raxx.request(:GET, "/pull")
      |> Raxx.set_header("last-event-id", "badtoken")

    response = Pull.handle_head(request, :state)
    assert response.status == 200
    assert {:ok, {%{id: "Done", lines: [json]}, ""}} = ServerSentEvent.parse(response.body)
    assert {:ok, %{"type" => _, "error" => error}} = Jason.decode(json)
    assert error["code"] == "invalid_request"
  end

  test "Returns no content for completed stream" do
    request =
      Raxx.request(:GET, "/pull")
      |> Raxx.set_header("last-event-id", "Done")

    response = Pull.handle_head(request, :state)
    assert response.status == 204
  end
end
