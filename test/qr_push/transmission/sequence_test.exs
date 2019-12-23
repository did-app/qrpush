defmodule QrPush.Transmission.SequenceTest do
  use ExUnit.Case

  alias QrPush.Transmission.Sequence

  test "ids increment for each called" do
    {:ok, 1} = Sequence.assign_id()
    {:ok, 2} = Sequence.assign_id()
  end
end
