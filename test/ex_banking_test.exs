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

  test "withdraw" do
    assert ExBanking.withdraw("yigit", 15, "EUR") == {:ok, 15}
  end

  test "get_balance" do
    assert ExBanking.get_balance("yigit", "EUR") == {:ok, 15}
  end

  test "send" do
    assert ExBanking.send("yigit", "sadic", 15, "EUR") == {:ok, 0, 15}
  end

  def create_user(user_name) do
    ExBanking.create_user(user_name)
  end
end
