# ChatCore

A small OTP-based chat backend, built as a hands-on introduction to Elixir
and the BEAM — coming from a Go/Rust systems background.

This is a learning project, not a production chat app. The goal was to
get a working feel for GenServer, Supervisor trees, and process-based
concurrency by building something small and real, rather than reading
about it.

## What this is

- A `GenServer` (`ChatCore.Room`) representing one chat room, holding
  message history in memory.
- A `DynamicSupervisor` (`ChatCore.RoomSupervisor`) that spawns rooms
  on demand at runtime.
- A `Registry` (`ChatCore.RoomRegistry`) for looking up rooms by name
  instead of passing PIDs around.
- An `Application` supervisor tying it all together with `:one_for_one`
  restart strategy — if one room crashes, only that room restarts;
  the rest of the system keeps running.

## What this isn't (yet)

- **No network layer.** Everything runs inside `iex`, not over HTTP or
  WebSockets. Phoenix Channels would be the next layer to add that.
- **No persistence.** Message history lives only in each room process's
  memory. Kill the process (or restart the app), and history is gone.
  Ecto + Postgres would be the next layer to add that.

## Setup

Requires Elixir 1.17+ / Erlang OTP 27+ (install via `asdf` or `mise`,
not `apt`/`brew`, to avoid version mismatches):

```bash
elixir --version
mix deps.get
mix test
```

All 10 tests should pass.

## Try it

```bash
iex -S mix
```

```elixir
iex> ChatCore.create_room("rust-lobby")
iex> ChatCore.create_room("go-lobby")

iex> ChatCore.send_message("rust-lobby", "Alice", "Hello Rustaceans!")
iex> ChatCore.send_message("rust-lobby", "Bob", "Is ownership hard?")
iex> ChatCore.send_message("go-lobby", "Charlie", "Let's talk about channels.")

iex> ChatCore.get_history("rust-lobby")
iex> ChatCore.get_history("go-lobby")   # fully isolated from rust-lobby
```

### See "let it crash" in action

```elixir
iex> {:ok, pid} = ChatCore.RoomSupervisor.create_room("crash-test")
iex> ChatCore.send_message("crash-test", "Alice", "before crash")
iex> Process.exit(pid, :kill)
iex> ChatCore.get_history("crash-test")
# => [] — the room process restarted under the same name,
#         but its in-memory state did not survive.

```

## Project structure
```


lib/
├── chat_core.ex               # public API
└── chat_core/
    ├── application.ex         # supervisor tree root
    ├── basics.ex              # standalone Elixir language tour
    ├── room.ex                # GenServer: one chat room
    └── room_supervisor.ex     # DynamicSupervisor: spawns rooms on demand
test/
├── room_test.exs
└── basics_test.exs
```

## Go / Rust → Elixir, quick mapping
| Concept                  | Go                 | Rust                      | Elixir                                  |
| ------------------------ | ------------------ | ------------------------- | --------------------------------------- |
| **Concurrency Unit**     | Goroutine          | Thread / Async Task       | BEAM Process                            |
| **Passing Data**         | Channel            | Channel / `Arc<Mutex<T>>` | Message passing (mailboxes)             |
| **Shared Mutable State** | Mutex-guarded data | `Arc<Mutex<T>>`           | Process-owned state (e.g., `GenServer`) |
| **Error Handling**       | `if err != nil`    | `Result<T, E>`            | "Let it crash"; supervisor restarts     |



## Next steps

- [ ] Phoenix Channels — expose this over real WebSockets
- [ ] Ecto + Postgres — persist room history across restarts
