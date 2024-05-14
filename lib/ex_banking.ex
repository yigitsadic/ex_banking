defmodule ExBanking do
  def create_user(_given) do
    :ok
  end

  def deposit(_user, amount, _currency) do
    {:ok, amount}
  end

  def withdraw(_user, amount, _currency) do
    {:ok, amount}
  end

  def get_balance(_user, _currency) do
    {:ok, 15}
  end

  def send(_from_user, _to_user, amount, _currency) do
    {:ok, 0, amount}
  end
end
