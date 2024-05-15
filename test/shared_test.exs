defmodule SharedTest do
  use ExUnit.Case

  test "should return wrong arguments response" do
    assert Shared.wrong_arguments_result() == {:error, :wrong_arguments}
  end

  test "should return not enough money result" do
    assert Shared.not_enough_money_result() == {:error, :not_enough_money}
  end

  test "should return user already exists result" do
    assert Shared.user_already_exists() == {:error, :user_already_exists}
  end

  test "should return user does not exist according to arg" do
    assert Shared.user_does_not_exists_result() == {:error, :user_does_not_exist}
    assert Shared.user_does_not_exists_result(:sender) == {:error, :sender_does_not_exist}
    assert Shared.user_does_not_exists_result(:receiver) == {:error, :receiver_does_not_exist}
  end

  test "should return too many requests according to arg" do
    assert Shared.too_many_requests_to_user_result() == {:error, :too_many_requests_to_user}

    assert Shared.too_many_requests_to_user_result(:sender) ==
             {:error, :too_many_requests_to_sender}

    assert Shared.too_many_requests_to_user_result(:receiver) ==
             {:error, :too_many_requests_to_receiver}
  end
end
