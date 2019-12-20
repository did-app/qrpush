defmodule QrPush.WWW do
  def child_spec([server_options]) do
    {:ok, port} = Keyword.fetch(server_options, :port)

    %{
      id: {__MODULE__, port},
      start: {__MODULE__, :start_link, [server_options]},
      type: :supervisor
    }
  end

  def init() do
    %{}
  end

  def start_link(server_options) do
    start_link(init(), server_options)
  end

  def start_link(config, server_options) do
    stack =
      Raxx.Stack.new(
        [],
        {__MODULE__.Router, config}
      )

    Ace.HTTP.Service.start_link(stack, server_options)
  end
end
