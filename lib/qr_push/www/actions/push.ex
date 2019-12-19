defmodule QrPush.WWW.Actions.Push do
  use Raxx.SimpleServer

  def handle_request(request, _state) do
    ["push", push_token] = request.path
    {:ok, _} = QrPush.push(push_token, request.body)
    response(:ok)
  end
end