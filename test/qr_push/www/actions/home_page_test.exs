defmodule QrPush.WWW.Actions.HomePageTest do
  use ExUnit.Case

  alias QrPush.WWW.Actions.HomePage

  test "returns the Raxx.Kit home page" do
    request = Raxx.request(:GET, "/")

    response = HomePage.handle_request(request, QrPush.WWW.init())

    assert response.status == 303
  end
end
