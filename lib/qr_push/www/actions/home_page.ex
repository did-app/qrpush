defmodule QrPush.WWW.Actions.HomePage do
  use Raxx.SimpleServer
  use Raxx.View, arguments: []

  @impl Raxx.SimpleServer
  def handle_request(_request = %{method: :GET}, _state) do
    response(:ok)
    |> render()
  end
end
