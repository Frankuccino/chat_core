defmodule ChatCore do
  alias ChatCore.RoomSupervisor

  @moduledoc """
  Public API. This is the module you actually call from `iex -S mix`
  Everything else (Room, RoomSupervisor, Registry) is internal plumbing.
  """

  alias ChatCore.{Room, RoomSupervisor}

  defdelegate create_room(name), to: RoomSupervisor
  defdelegate send_message(room, user, content), to: Room
  defdelegate get_history(room), to: Room
end
