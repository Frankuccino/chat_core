defmodule ChatCore.RoomSupervisor do
  @moduledoc """
  Thin wrapper around DynamicSupervisor so callers never touch the
  supervisor directly. This is what lets you say "create a room called
  whatever, whenever" instead of hardcoding a fixed list of rooms in
  application.ex.
  """

  alias ChatCore.Room

  @doc """
  Starts a new Room process under the DynamicSupervisor. If a room with
  this name already exists, return the existing PID instead of crashing -
  handling the race gracefully rather than letting two rooms collid.
  """

  def create_room(room_name) do
    child_spec = %{
      id: Room,
      start: {Room, :start_link, [room_name]},
      restart: :transient
    }

    case DynamicSupervisor.start_child(ChatCore.RoomSupervisor, child_spec) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      error -> error
    end
  end

  @doc "Lists how many rooms are currently alive."
  def count_rooms do
    DynamicSupervisor.count_children(ChatCore.RoomSupervisor)
  end
end
