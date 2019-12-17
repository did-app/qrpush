defmodule QrPush.WWW.Actions.HomePage do
  use Raxx.SimpleServer
  use QrPush.WWW.Layout, arguments: [:greeting, :csrf_token]
  alias Raxx.Session

  @impl Raxx.SimpleServer
  def handle_request(request = %{method: :GET}, state) do
    {:ok, session} = Session.extract(request, state.session_config)

    {csrf_token, session} = Session.get_csrf_token(session)
    {flash, session} = Session.pop_flash(session)

    greeting = QrPush.welcome_message(session[:name])

    response(:ok)
    |> Session.embed(session, state.session_config)
    |> render(greeting, csrf_token, flash: flash)
  end

  def handle_request(request = %{method: :POST}, state) do
    data = URI.decode_query(request.body)
    {:ok, session} = Session.extract(request, data["_csrf_token"], state.session_config)

    case data do
      %{"name" => name} ->
        session =
          session
          |> Map.put(:name, name)
          |> Session.put_flash(:info, "Successfully changed name")

        redirect("/")
        |> Session.embed(session, state.session_config)

      _ ->
        redirect("/")
    end
  end

  # Template helper functions.
  # Add shared helper functions to QrPush.WWW.Layout.
end
