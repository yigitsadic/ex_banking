defmodule ExBankingTest do
  use ExUnit.Case

  test "create_user" do
    assert ExBanking.create_user("yigit") == :ok
  end

  test "validate input for user create" do
    bad_inputs = [
      15,
      nil,
      false,
      %{},
      [],
      "",
      "  "
    ]

    Enum.each(bad_inputs, fn inpt ->
      assert ExBanking.create_user(inpt) == {:error, :wrong_arguments}
    end)
  end

  test "cannot create a user second time" do
    assert :ok == ExBanking.create_user("lorem")
    assert {:error, :user_already_exists} == ExBanking.create_user("lorem")
  end

  test "deposit name should be valid" do
    assert ExBanking.deposit("", 15, "EUR") == {:error, :wrong_arguments}
  end

  test "deposit currency should be valid" do
    assert ExBanking.deposit("yigit", 15, "") == {:error, :wrong_arguments}
  end

  test "deposit amount should be valid" do
    assert ExBanking.deposit("yigit", "15", "USD") == {:error, :wrong_arguments}
    assert ExBanking.deposit("yigit", 0, "USD") == {:error, :wrong_arguments}
    assert ExBanking.deposit("yigit", -1, "USD") == {:error, :wrong_arguments}
  end

  test "deposit user should exist" do
    assert ExBanking.deposit("non_exist", 15, "USD") == {:error, :user_does_not_exist}
  end

  test "deposit should increase balance" do
    create_user("sinem")

    {:ok, first_result} = ExBanking.deposit("sinem", 1, "USD")
    {:ok, second_result} = ExBanking.deposit("sinem", 1, "USD")

    user = Core.details("sinem")
    result = Structs.User.get_currency(user, "USD")

    assert first_result == 1
    assert second_result == 2
    assert result == 2
  end

  test "withdraw should validate user name" do
    assert ExBanking.withdraw("", 15, "EUR") == {:error, :wrong_arguments}
  end

  test "withdraw should validate existence of user" do
    assert ExBanking.withdraw("yigit", 15, "EUR") == {:error, :user_does_not_exist}
  end

  test "withdraw should validate amount" do
    assert ExBanking.withdraw("yigit", 0, "EUR") == {:error, :wrong_arguments}
    assert ExBanking.withdraw("yigit", -2, "EUR") == {:error, :wrong_arguments}
  end

  test "withdraw should validate currency" do
    assert ExBanking.withdraw("yigit", 2, "") == {:error, :wrong_arguments}
  end

  test "withdraw should validate does user's balance enough" do
    ExBanking.create_user("yigit")

    assert ExBanking.withdraw("yigit", 10, "USD") == {:error, :not_enough_money}
  end

  test "after withdraw balance should be decreased" do
    ExBanking.create_user("yigit")
    ExBanking.deposit("yigit", 10, "USD")

    {:ok, new_balance} = ExBanking.withdraw("yigit", 5, "USD")

    assert new_balance == 5
    assert {:ok, new_balance} == ExBanking.get_balance("yigit", "USD")
  end

  test "get_balance user should be valid" do
    assert ExBanking.get_balance("", "EUR") == {:error, :wrong_arguments}
  end

  test "get_balance currency should be valid" do
    assert ExBanking.get_balance("yigit", "") == {:error, :wrong_arguments}
  end

  test "get_balance user should exists" do
    assert ExBanking.get_balance("yigit", "EUR") == {:error, :user_does_not_exist}
  end

  test "get_balance should respond correctly" do
    ExBanking.create_user("yigit")
    assert ExBanking.get_balance("yigit", "USD") == {:ok, 0}

    ExBanking.deposit("yigit", 10, "USD")
    assert ExBanking.get_balance("yigit", "USD") == {:ok, 10}
  end

  test "send" do
    assert ExBanking.send("yigit", "sadic", 15, "EUR") == {:ok, 0, 15}
  end

  def create_user(user_name) do
    ExBanking.create_user(user_name)
  end
end
