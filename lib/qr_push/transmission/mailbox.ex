defmodule QrPush.Transmission.Mailbox do
  use GenServer
  require OK

  alias QrPush.Error

  # TODO after timout you should die
  @enforce_keys [:id, :target, :follower, :pull_check, :push_check]
  defstruct @enforce_keys

  def setup(target) do
    {:ok, id} = QrPush.Transmission.Sequence.assign_id()
    pull_secret = :crypto.strong_rand_bytes(16)
    push_secret = :crypto.strong_rand_bytes(6)
    # Need to keep sending pull token, might be easier encrypted
    pull_token = Base.encode32(<<id::32, pull_secret::binary>>)
    push_token = Base.encode32(<<id::32, push_secret::binary>>)
    tokens = %{pull_token: pull_token, push_token: push_token}

    state = %__MODULE__{
      id: id,
      target: target,
      follower: nil,
      pull_check: mask(pull_secret),
      push_check: mask(push_secret)
    }

    {state, tokens}
  end

  def start_link(target) do
    {state, tokens} = setup(target)

    case GenServer.start_link(__MODULE__, state, name: {:global, {__MODULE__, state.id}}) do
      {:ok, pid} ->
        {:ok, pid, tokens}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:follow, pid, pull_secret}, _from, state) do
    %__MODULE__{pull_check: pull_check} = state

    case secure_compare(mask(pull_secret), pull_check) do
      true ->
        monitor = Process.monitor(pid)
        state = %__MODULE__{state | follower: {monitor, pid}}
        # TODO if message send
        {:reply, :ok, state}

      false ->
        {:reply,
         {:error,
          Error.operation_denied("Token was invalid for streaming messages from mailbox")}, state}
    end
  end

  def handle_call({:redirect, push_secret}, _from, state) do
    %__MODULE__{push_check: push_check} = state

    case secure_compare(mask(push_secret), push_check) do
      true ->
        %__MODULE__{target: target} = state
        {:reply, {:ok, target}, state}

      false ->
        {:reply, {:error, Error.operation_denied("Token was invalid accessing mailbox")}, state}
    end
  end

  def handle_call({:push, push_secret, message}, _from, state) do
    %__MODULE__{push_check: push_check} = state

    case secure_compare(mask(push_secret), push_check) do
      true ->
        case state.follower do
          {_monitor, pid} ->
            send(pid, message)
            {:reply, {:ok, :ok}, state}
        end

      false ->
        {:reply,
         {:error, Error.operation_denied("Token was invalid for sending messages to mailbox")},
         state}
    end
  end

  def handle_info do
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
