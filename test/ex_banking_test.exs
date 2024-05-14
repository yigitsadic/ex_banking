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

  test "send should validate sender name" do
    assert ExBanking.send("", "yigit", 15, "USD") == {:error, :wrong_arguments}
  end

  test "send should validate receiver name" do
    assert ExBanking.send("yigit", "", 15, "USD") == {:error, :wrong_arguments}
  end

  test "send should validate currency" do
    assert ExBanking.send("yigit", "sinem", 15, "") == {:error, :wrong_arguments}
  end

  test "send should validate amount" do
    assert ExBanking.send("yigit", "sinem", -15, "USD") == {:error, :wrong_arguments}
    assert ExBanking.send("yigit", "sinem", "-15", "USD") == {:error, :wrong_arguments}
    assert ExBanking.send("yigit", "sinem", 0, "USD") == {:error, :wrong_arguments}
  end

  test "send should check existance of sender" do
    ExBanking.create_user("sinem")

    assert ExBanking.send("yigit", "sinem", 15, "USD") == {:error, :sender_does_not_exist}
  end

  test "send should check existance of receiver" do
    ExBanking.create_user("yigit")

    assert ExBanking.send("yigit", "sinem", 15, "USD") == {:error, :receiver_does_not_exist}
  end

  test "send should check balance of sender" do
    ExBanking.create_user("yigit")
    ExBanking.create_user("sinem")

    assert ExBanking.send("yigit", "sinem", 15, "USD") == {:error, :not_enough_money}
  end

  test "send should successfully transfer amount" do
    ExBanking.create_user("yigit")
    ExBanking.create_user("sinem")
    ExBanking.deposit("yigit", 40, "USD")
    result = ExBanking.send("yigit", "sinem", 10, "USD")

    assert result == {:ok, 30, 10}
    assert ExBanking.get_balance("yigit", "USD") == {:ok, 30}
    assert ExBanking.get_balance("sinem", "USD") == {:ok, 10}
  end

  def create_user(user_name) do
    ExBanking.create_user(user_name)
  end
end
