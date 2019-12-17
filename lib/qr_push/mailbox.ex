defmodule QrPush.Mailbox do
  use GenServer

  @enforce_keys [:id, :target, :follower]
  defstruct @enforce_keys

  def start_link(id, target) do
    state = %__MODULE__{id: id, target: target, follower: nil}
    GenServer.start_link(__MODULE__, state, name: {:global, {__MODULE__, id}})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:redirect, _}, _from, state) do
    %__MODULE__{target: target} = state
    {:reply, {:ok, target}, state}
  end

  def handle_call({:push, message}, _from, state) do
    case state.follower do
      {monitor, pid} ->
        send(pid, message)
        {:reply, :ok, state}
    end
  end

  def handle_call({:follow, pid, 0}, _from, state) do
    monitor = Process.monitor(pid)
    state = %__MODULE__{state | follower: {monitor, pid}}
    # TODO if message send
    {:reply, :ok, state}
  end
end
