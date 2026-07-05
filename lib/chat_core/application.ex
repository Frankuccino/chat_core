defmodule ChatCore.Application do
  # This is the OTP Application behavior. Think of it as the root
  # "main()" - except instead of running code top to bottom, it declares
  # a *tree* of processes and hands them to a Supervisor to keep alive.
  #
  # Go analogy: like a main() that starts N goroutines, but if any of
  # them panic, something automatically restarts *just that goroutine*
  # instead of crashing your whole program.
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # A Registry lets us look up a Room process by name (a string)
      # instead of needing to pass its PID around everywhere
      # This replaces the fragile `:global` tuple approach
      # Registry is the idiomatic, local, and fast way.
      {Registry, keys: :unique, name: ChatCore.RoomRegistry},

      # DynamicSupervisor lets us spawn new ChatRoom processes on demand
      # at runtime (e.g. when a user creates a new room), rather than
      # declaring a fixed list of children up front.
      {DynamicSupervisor, strategy: :one_for_one, name: ChatCore.RoomSupervisor}
    ]

    # :one_for_one means: if a child crashes, restart only that child,
    # not its siblings. This is the "let it crash" philosophy in action
    # isolated failure, isolated recovery.
    opts = [strategy: :one_for_one, name: ChatCore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
