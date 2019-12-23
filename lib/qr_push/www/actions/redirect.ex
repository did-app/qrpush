defmodule QrPush.WWW.Actions.Redirect do
  use Raxx.SimpleServer

  def handle_request(request = %{method: :GET}, _state) do
    [push_token] = request.path
    {:ok, target} = QrPush.Transmission.redirect(push_token)
    extra_query = "qrpu.sh=#{request.scheme}://#{request.authority}/push/#{push_token}"
    uri = URI.parse(target)

    query =
      case uri.query do
        nil ->
          extra_query

        query ->
          query <> "&" <> extra_query
      end

    redirect(%{uri | query: query} |> URI.to_string())
  end
end
