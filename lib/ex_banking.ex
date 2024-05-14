defmodule ExBanking do
  import Validators

  @wrong_arguments_result {:error, :wrong_arguments}
  @user_does_not_exists_result {:error, :user_does_not_exist}

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

  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number()}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) do
    with {:user_name_valid, true} <- {:user_name_valid, valid_string?(user)},
         {:currency_valid, true} <- {:currency_valid, valid_string?(currency)},
         {:amount_valid, true} <- {:amount_valid, valid_number?(amount)},
         _ <- Core.start_link(user),
         found_user <- Core.details(user),
         {:user_exists, true} <- {:user_exists, Structs.User.user_exists?(found_user)},
         new_balance <- Core.update_balance(user, amount, currency) do
      {:ok, new_balance}
    else
      {:user_name_valid, false} -> @wrong_arguments_result
      {:currency_valid, false} -> @wrong_arguments_result
      {:amount_valid, false} -> @wrong_arguments_result
      {:user_exists, false} -> @user_does_not_exists_result
    end
  end

  def withdraw(_user, amount, _currency) do
    {:ok, amount}
  end

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    with {:user_name_valid, true} <- {:user_name_valid, valid_string?(user)},
         {:currency_valid, true} <- {:currency_valid, valid_string?(currency)},
         _ <- Core.start_link(user),
         found_user <- Core.details(user),
         {:user_exists, true} <- {:user_exists, Structs.User.user_exists?(found_user)},
         balance <- Core.get_balance(user, currency) do
      {:ok, balance}
    else
      {:user_name_valid, false} -> @wrong_arguments_result
      {:currency_valid, false} -> @wrong_arguments_result
      {:user_exists, false} -> @user_does_not_exists_result
    end
  end

  def send(_from_user, _to_user, amount, _currency) do
    {:ok, 0, amount}
  end
end
