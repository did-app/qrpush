defmodule QrPush.Sequence do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def assign_id() do
    GenServer.call(__MODULE__, :assign)
  end

  ## Sever callbacks

  def init(0) do
    {:ok, 0}
  end

  def handle_call(:assign, _from, count) do
    new = count + 1
    {:reply, {:ok, new}, new}
  end
end
