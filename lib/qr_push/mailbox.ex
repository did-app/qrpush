defmodule QrPush.Mailbox do
  use GenServer

  # TODO after timout you should die
  @enforce_keys [:id, :target, :follower, :pull_check, :push_check]
  defstruct @enforce_keys

  def start_link(id, target, pull_check, push_check) do
    state = %__MODULE__{
      id: id,
      target: target,
      follower: nil,
      pull_check: pull_check,
      push_check: push_check
    }

    GenServer.start_link(__MODULE__, state, name: {:global, {__MODULE__, id}})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:redirect, push_secret}, _from, state) do
    %__MODULE__{push_check: push_check} = state

    case secure_compare(mask(push_secret), push_check) do
      true ->
        %__MODULE__{target: target} = state
        {:reply, {:ok, target}, state}
    end
  end

  def handle_call({:push, push_secret, message}, _from, state) do
    %__MODULE__{push_check: push_check} = state

    case secure_compare(mask(push_secret), push_check) do
      true ->
        case state.follower do
          {_monitor, pid} ->
            send(pid, message)
            {:reply, :ok, state}
        end
    end
  end

  # connection
  def handle_call({:follow, pid, pull_secret}, _from, state) do
    %__MODULE__{pull_check: pull_check} = state

    case secure_compare(mask(pull_secret), pull_check) do
      true ->
        IO.inspect(pull_secret)
        monitor = Process.monitor(pid)
        state = %__MODULE__{state | follower: {monitor, pid}}
        # TODO if message send
        {:reply, :ok, state}
    end
  end

  defp mask(secret) do
    Base.encode32(:crypto.hash(:sha256, secret))
  end

  @doc """
  Compares the two binaries in constant-time to avoid timing attacks.
  See: http://codahale.com/a-lesson-in-timing-attacks/
  """

  def secure_compare(left, right) do
    if byte_size(left) == byte_size(right) do
      secure_compare(left, right, 0) == 0
    else
      false
    end
  end

  import Bitwise, only: [|||: 2, ^^^: 2]

  defp secure_compare(<<x, left::binary>>, <<y, right::binary>>, acc) do
    secure_compare(left, right, acc ||| x ^^^ y)
  end

  defp secure_compare(<<>>, <<>>, acc) do
    acc
  end
end
