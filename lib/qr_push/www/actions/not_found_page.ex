defmodule QrPush.WWW.Actions.NotFoundPage do
  use Raxx.SimpleServer

  @impl Raxx.SimpleServer
  def handle_request(_request, _state) do
    response(:not_found)
  end
end
