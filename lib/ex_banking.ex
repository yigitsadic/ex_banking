defmodule ExBanking do
  import Validators

  @wrong_arguments_result {:error, :wrong_arguments}

  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_bitstring(user) do
    with {:user_name_valid, true} <- {:user_name_valid, valid_string?(user)},
         _ <- Core.start_link(user),
         found_user <- Core.details(user),
         {:user_exists, false} <- {:user_exists, Structs.User.user_exists?(found_user)},
         _ <- Core.create_user(user) do
      :ok
    else
      {:user_name_valid, false} -> @wrong_arguments_result
      {:user_exists, true} -> {:error, :user_already_exists}
    end
  end

  def create_user(_any), do: @wrong_arguments_result

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
