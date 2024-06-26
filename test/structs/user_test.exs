defmodule Structs.UserTest do
  use ExUnit.Case
  alias Structs.User

  test "can retrieve a currency value" do
    user1 = User.new("user1")

    assert User.get_currency(user1, "USD") == 0

    user1 = Map.put(user1, :currencies, %{"USD" => 15.75})
    assert User.get_currency(user1, "USD") == 15.75
  end

  test "should add currency" do
    user = User.new("user")
    user2 = User.new("user2")

    user = User.add_currency(user, 15.75, "USD")
    user = User.add_currency(user, 27, "EUR")
    user = User.add_currency(user, 10, "USD")

    assert User.get_currency(user, "USD") == 25.75
    assert User.get_currency(user, "EUR") == 27

    assert User.get_currency(user2, "USD") == 0
  end

  test "can check given user withdraw currency" do
    user = User.new("user")

    user = User.add_currency(user, 15.75, "USD")

    refute User.can_withdraw?(user, 15.76, "USD")
    assert User.can_withdraw?(user, 15.75, "USD")
    refute User.can_withdraw?(user, 15.75, "EUR")
    assert User.can_withdraw?(user, 14.75, "USD")
  end

  test "it should return queue full if it is" do
    user = User.new("user")
    user = Map.put(user, :event_queue, 11)

    assert User.queue_full?(user)
    assert User.queue_full?(5) == :error
    assert User.queue_full?("5") == :error
    assert User.queue_full?(nil) == :error
    assert User.queue_full?(%{}) == :error

    user = Map.put(user, :event_queue, 9)
    refute User.queue_full?(user)
  end

  test "it should increment queue" do
    user = User.new("user")

    user = User.increment_queue(user)
    user = User.increment_queue(user)

    assert user.event_queue == 2
  end

  test "it should decrement queue" do
    user = User.new("user")

    assert user.event_queue == 0

    user = User.decrement_queue(user)
    user = User.decrement_queue(user)

    # Ensure it won't becomes negative.
    assert user.event_queue == 0

    user = User.increment_queue(user)
    user = User.increment_queue(user)
    user = User.decrement_queue(user)

    assert user.event_queue == 1
  end

  test "it can check a map is valid user struct" do
    map1 = %{age: 15}
    map2 = %{book_name: "Elixir"}
    map3 = User.new("yigit")

    assert User.user_exists?(map3)
    refute User.user_exists?(map1)
    refute User.user_exists?(map2)
  end
end
