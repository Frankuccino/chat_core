defmodule ChatCore.RoomTest do
  alias ChatCore.RoomSupervisor
  # async: true is safe here because each test creates a uniquely named
  # room - no shared mutable state between tests. This is the kind of 
  # thing that's hard to get right in other languages' test suites
  # without careful setup/teardown.
  use ExUnit.Case, async: true

  alias ChatCore.{Room, RoomSupervisor}

  test "a room starts empty" do
    {:ok, _pid} = RoomSupervisor.create_room("test-room-order")

    Room.send_message("test-room-order", "alice", "hi")
    Room.send_message("test-room-order", "bob", "hey")

    history = Room.get_history("test-room-order")

    assert length(history) == 2
    assert Enum.map(history, & &1.user) == ["alice", "bob"]
  end

  test "two rooms are fully isolated from each other" do
    {:ok, _} = RoomSupervisor.create_room("room-a")
    {:ok, _} = RoomSupervisor.create_room("room-b")

    Room.send_message("room-a", "alice", "only in room a")

    assert length(Room.get_history("room-a")) == 1
    assert Room.get_history("room-b") == []
  end
end
