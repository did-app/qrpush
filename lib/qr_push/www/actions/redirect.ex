defmodule QrPush.WWW.Actions.Redirect do
  use Raxx.SimpleServer

  def handle_request(request = %{method: :GET}, _state) do
    [push_token] = request.path
    {:ok, target} = QrPush.redirect(push_token)

    redirect(target <> "?qrpu.sh=#{request.scheme}://#{request.authority}/push/#{push_token}")
  end
end
