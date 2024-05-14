defmodule CoreTest do
  use ExUnit.Case

  setup do
    user_name = "yigit"
    {:ok, pid} = Core.start_link(user_name)

    {:ok, pid: pid, user_name: user_name}
  end

  test "initial state should be an empty map", state do
    assert Core.details(state[:user_name]) == %{}
  end

  test "it should update state with create user", state do
    result = Core.create_user(state[:user_name])
    expected_output = Structs.User.new(state[:user_name])

    assert result == expected_output
    assert Core.details(state[:user_name]) == expected_output
  end

  test "server_name_for should create unified reference" do
    assert Core.server_name_for("yigit") == {:global, "user_yigit"}
  end

  test "it should be able to increment job queue async" do
    user = "john"

    Core.start_link(user)
    Core.create_user(user)

    Core.increment_queue_for(user)
    Core.increment_queue_for(user)
    Core.increment_queue_for(user)

    assert Map.get(Core.details(user), :event_queue, 0) == 3
  end

  test "it should be able to decrement job queue async" do
    user = "john"

    Core.start_link(user)
    Core.create_user(user)

    Core.increment_queue_for(user)
    Core.increment_queue_for(user)
    Core.increment_queue_for(user)
    Core.decrement_queue_for(user)

    assert Map.get(Core.details(user), :event_queue, 0) == 2
  end
end
