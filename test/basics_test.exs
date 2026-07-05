defmodule ChatCore.BasicsTest do
  use ExUnit.Case, async: true

  alias ChatCore.Basics

  test "pattern matching examples return expected bindings" do
    result = Basics.match_examples()
    assert result.x == 1
    assert result.value == 42
    assert result.first == 10
    assert result.rest == [20, 30]
  end

  test "piped and unpiped versions produce identical results" do
    assert Basics.pipe_example(10) == Basics.pipe_example_unpiped(10)
    assert Basics.pipe_example(10) == "00011"
  end

  test "recursive sum matches Enum.sum" do
    list = [1, 2, 3, 4, 5]
    assert Basics.sum_list(list) == Basics.sum_list_idiomatic(list)
    assert Basics.sum_list(list) == 15
  end

  test "struct-based describe dispatches on role via pattern match" do
    admin = %Basics.User{name: "Frank", role: :admin}
    member = %Basics.User{name: "Bob", role: :member}

    assert Basics.describe(admin) == "Frank is an admin"
    assert Basics.describe(member) == "Bob is a member"
  end

  test "raw spawned process replies over message passing" do
    # The =~ is a substring matching like SQL's 'word%'
    assert Basics.spawn_raw_process() =~ "hello from"
  end

  test "agent holds mutable-looking state via serialized updates" do
    assert Basics.agent_counter_demo() == 2
  end

  test "task runs concurrently and returns its result" do
    assert Basics.task_demo() == Enum.sum(1..1_000_000)
  end
end
