defmodule QrPush.WWW do
  def child_spec([server_options]) do
    {:ok, port} = Keyword.fetch(server_options, :port)

    %{
      id: {__MODULE__, port},
      start: {__MODULE__, :start_link, [server_options]},
      type: :supervisor
    }
  end

  # This works even if the reference file is not available at start up,
  # i.e. it will be generated by npm scripts.
  @external_resource "lib/qr_push/www/public/main.css"
  @external_resource "lib/qr_push/www/public/main.js"
  options = [source: Path.join(__DIR__, "www/public")]

  @static_setup (if(Mix.env() == :dev) do
                   options
                 else
                   Raxx.Static.setup(options)
                 end)

  def init() do
    %{}
  end

  def start_link(server_options) do
    start_link(init(), server_options)
  end

  def start_link(config, server_options) do
    stack =
      Raxx.Stack.new(
        [
          {Raxx.Static, @static_setup}
        ],
        {__MODULE__.Router, config}
      )

    Ace.HTTP.Service.start_link(stack, server_options)
  end
end