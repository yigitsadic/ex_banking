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

  test "it should be able to increment or decrement balance of a user" do
    user = "john"

    Core.start_link(user)
    Core.create_user(user)

    result1 = Core.update_balance(user, 15, "USD")
    result2 = Core.update_balance(user, 15, "USD")
    result3 = Core.update_balance(user, -10, "USD")

    assert result1 == 15
    assert result2 == 30
    assert result3 == 20

    assert Core.get_balance(user, "USD") == 20
  end

  test "it can read balance of user with a currency" do
    user = "john"
    Core.start_link(user)
    Core.create_user(user)

    Core.update_balance(user, 15, "USD")

    assert Core.get_balance(user, "EUR") == 0
    assert Core.get_balance(user, "USD") == 15
  end
end
