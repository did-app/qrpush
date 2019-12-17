defmodule QrPush.Counter do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def init(0) do
    {:ok, 0}
  end

  def handle_call({:assign}, _from, count) do
    new = count + 1
    {:reply, new, new}
  end
end
