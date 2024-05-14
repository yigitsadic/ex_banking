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
end
