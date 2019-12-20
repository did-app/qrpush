defmodule QrPush.WWW.Actions.HomePage do
  use Raxx.SimpleServer

  @web_host (if(Mix.env() == :prod) do
               # TODO https
               "http://www.qrpu.sh"
             else
               "http://localhost:5000"
             end)

  @impl Raxx.SimpleServer
  def handle_request(_request = %{method: :GET}, _state) do
    redirect(@web_host)
  end
end
