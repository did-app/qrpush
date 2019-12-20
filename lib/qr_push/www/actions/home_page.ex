defmodule QrPush.WWW.Actions.HomePage do
  use Raxx.SimpleServer

  @impl Raxx.SimpleServer
  def handle_request(_request = %{method: :GET}, _state) do
    # TODO https
    redirect("http://www.qrpu.sh")
  end
end
