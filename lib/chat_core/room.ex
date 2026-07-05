defmodule ChatCore.Room do
  @moduledoc """
  A stateful process representing one chat room.

    This is a GenServer - Elixir/OTP's standard "process that holds state"
    and responds to messages" abstraction. Every GenServer is really just
    a loop: receive a mesage, run a callback, get a new state, loop again.
    You never touch that loop yourself; OTP writes it for you.

    Rust/Go comparison:
    - Rust: like an actor owning a Mutex<State>, except there's no lock - 
      only one process ever touches this state, so there's nothing to 
      contend for.
    - Go: like a goroutine with a `for { select {...} }` loop reading off
      channels, except the "channel" is the process's own mailbow, and 
      GenServer.call/cast is doing the send/receive plumbing for you.
  """

  use GenServer

  #  ---------------------------------------------------------------------
  # Client API - these run in the CALLER's process. They jsut format a
  # message and send it to the Room process; they don't touch state.
  # ---------------------------------------------------------------------

  def start_link(room_name) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(room_name))
  end

  @doc "Fire-and-forget: like pushing to an unbuffered Go channel and not waiting."
  def send_message(room_name, user, content) do
    GenServer.cast(via_tuple(room_name), {:send_message, user, content})
  end

  @doc "Synchronous: blocks until the Room replies. Like a Go channel round-trip"
  def get_history(room_name) do
    GenServer.call(via_tuple(room_name), :get_history)
  end

  # ---------------------------------------------------------------------
  # Server callbacks - these run INSIDE the Room process itself.
  # ---------------------------------------------------------------------

  @impl true
  def init(_initial_state) do
    # State here is just a plain list. No struct required, but see
    # basics.ex for when/why you'd reach for a struct instead.
    {:ok, []}
  end

  @impl true
  def handle_cast({:send_message, user, content}, messages) do
    new_message = %{user: user, content: content, timestamp: DateTime.utc_now()}
    # Prepending is O(1) because Elixir lists are singly linked lists.
    # Appending with `++` would be O(n) - a common beginner footgun.
    {:noreply, [new_message | messages]}
  end

  @impl true
  def handle_call(:get_history, _from, messages) do
    {:reply, Enum.reverse(messages), messages}
  end

  defp via_tuple(room_name) do
    {:via, Registry, {ChatCore.RoomRegistry, room_name}}
  end
end
