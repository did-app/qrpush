defmodule QrPush.WWW.Layout do
  use Raxx.View.Layout,
    optional: [flash: %{}, title: "qr_push"]

  # Shared template helper functions.
  # Use `~E` or the `partial/3` macro to generate HTML safely.

  def display_date(date) do
    Date.to_iso8601(date)
  end

  def home_page_link() do
    ~E"""
    <a href="/">Home</a>
    """
  end

  partial(:page_header, [:title])
end
