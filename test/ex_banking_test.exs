defmodule ExBankingTest do
  use ExUnit.Case

  test "create_user" do
    assert ExBanking.create_user("yigit") == :ok
  end

  test "deposit" do
    assert ExBanking.deposit("yigit", 15, "EUR") == {:ok, 15}
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
end
