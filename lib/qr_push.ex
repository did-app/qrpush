defmodule QrPush do
  def generate(url) do
    svg =
      url
      |> EQRCode.encode()
      |> EQRCode.svg()

    "data:image/svg+xml;base64," <> Base.encode64(svg)
  end
end
