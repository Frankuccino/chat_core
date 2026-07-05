defmodule ChatCore.Basics do
  @moduledoc """
  A tour of core Elixir constructs, framed against what you already know
  from Go and Rust. This module isn't meant to be "used"- open it in 
  iex (`iex -S mix`) and call functions from here one at a time, reading
  the comments as you go. Everything is plain function soyou can poke 
  at it interactively.

  Suggested order  to try things in iex:
  ChatCore.Basics.match_examples()
  ChatCore.Basics.pipe_example(19)
  ChatCore.Basics.sum_list([1,2,3,4,5])
  ChatCore.Basics.describe(%ChatCode.Basics.User{name: "Frank", role: :admin})
  ChatCore.Basics.spawn_raw_process()
  """

  def match_examples do
    # this binds x to 1. Standard case.
    x = 1

    # This only works because 1 == 1. Try changing the right side and
    # You'll get a MatchError - This is Elixir's version of an assert.
    1 = x

    # Destructuring a tuple - Like Go's `a, b := pair()` but pattern-based.
    {:ok, value} = {:ok, 42}

    # Destructuring a list, splitting head from tail - the recursion
    # workhorse. `[head | tail]` is the same shape you'll see everywhere.
    [first | rest] = [10, 20, 30]

    # Ignoring a value with `_` - like Go's blank identifier.
    {_, second} = {"ignored", "kept"}

    %{x: x, value: value, first: first, rest: rest, second: second}
  end

  # ----------------------------------------------------------------------------
  # 2. The pipe operator - `|>` | and > takes the left result and feeds it as
  #    the FIRST argument of the right function. This is the single
  #    biggest "Elixir feels different" idiom. It replaces deeply
  #    nested function calls with a left-to-right reading order.
  # ----------------------------------------------------------------------------

  def pipe_example(n) do
    n
    |> Kernel.+(1)
    |> Integer.to_string()
    |> String.pad_leading(5, "0")
  end

  # Equivalent WITHOUT the pipe, for comparison - read it inside-out:
  def pipe_example_unpiped(n) do
    String.pad_leading(Integer.to_string(Kernel.+(n, 1)), 5, "0")
  end

  # ----------------------------------------------------------------------------
  # 3. Recursion instead of loops. There is no `for` loop that mutates 
  #    a variable - state changes by passing new values into the next
  #    call. This is the direct consequence of immutability.
  # ----------------------------------------------------------------------------

  # Entry point that passes the initial accumulator of 0
  def sum_list(list), do: sum_list(list, 0)

  # Multiple function heads with pattern matching in the arguments
  # replace `if/else` here. The empty-list case is the base case.
  # Base case: when the list is empty, return the accumulator
  defp sum_list([], acc), do: acc
  # Recursive case: add head to the accumulator and recurse
  defp sum_list([head | tail], acc) do
    sum_list(tail, acc + head)
  end

  # In real code you'd just use Enum/Stream, which are the standard
  # library's built-in, optimized recursion:
  # Idiomatic Elixir using the built-in Enum module
  def sum_list_idiomatic(list), do: Enum.sum(list)

  # ----------------------------------------------------------------------------
  # 4. Structs - Elixir's closest thing to Go structs / Rust structs.
  #    Defined with `defstruct`, they're really just tagged maps with
  #    compile-time enforced fields.
  # ----------------------------------------------------------------------------
  defmodule User do
    @enforce_keys [:name]
    defstruct name: nil, role: :guest
  end

  # Guards (`when`) and extra condition to a pattern match - like a 
  # Rust match arm with an `if` guard clause.
  def describe(%User{role: :admin, name: name}), do: "#{name} is an admin"

  def describe(%User{role: role, name: name}) when role in [:guest, :member] do
    "#{name} is a #{role}"
  end

  # ----------------------------------------------------------------------------
  # 5. Raw processes - before GenServer, this is what's actually
  #    underneath it. Worth seeing once so GenServer doesn't feel
  #    like magic.
  # ----------------------------------------------------------------------------
  def spawn_raw_process do
    parent = self()

    # spawn/1 starts a totally independent, isolated process. No shared
    # memory with the caller at all - unlike a Go goroutine, which CAN
    # share memory (and therefore CAN race) with its parent.

    pid =
      spawn(fn ->
        receive do
          {:ping, from} -> send(from, {:pong, "hello from #{inspect(self())}"})
        end
      end)

    send(pid, {:ping, parent})

    receive do
      {:pong, msg} -> msg
    after
      1000 -> "timeot - no reply"
    end
  end

  # ----------------------------------------------------------------------------
  # 6. Agent - a GenServer wrapper for the common "just hold some
  # state" case, when you don't need custom handle_call/handle_cast
  # logic. Good for simple counters/caches.
  # ----------------------------------------------------------------------------
  def agent_counter_demo do
    {:ok, agent} = Agent.start_link(fn -> 0 end)
    Agent.update(agent, fn count -> count + 1 end)
    Agent.update(agent, fn count -> count + 1 end)
    Agent.get(agent, fn count -> count end)
  end

  # ----------------------------------------------------------------------------
  # 7. Task - for one-off concurret work where you want the result
  #    back, closer to Rust's tokio::spawn + .await, or a Go goroutine
  #    + channel used exactly once.
  # ----------------------------------------------------------------------------
  def task_demo do
    task = Task.async(fn -> Enum.sum(1..1_000_000) end)
    # do other work here while it runs concurrently
    Task.await(task)
  end
end
