defmodule ExBanking do
  import Validators

  @wrong_arguments_result {:error, :wrong_arguments}
  @user_does_not_exists_result {:error, :user_does_not_exist}
  @not_enough_money_result {:error, :not_enough_money}
  @too_many_requests_to_user_result {:error, :too_many_requests_to_user}

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
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) do
    with {:user_name_valid, true} <- {:user_name_valid, valid_string?(user)},
         {:currency_valid, true} <- {:currency_valid, valid_string?(currency)},
         {:amount_valid, true} <- {:amount_valid, valid_number?(amount)},
         {:user_exists, true, found_user} <- check_users_existance(:user_exists, user),
         {:queue_full, false} <- {:queue_full, Structs.User.queue_full?(found_user)},
         new_balance <- Core.update_balance(user, amount, currency) do
      {:ok, new_balance: new_balance}
    else
      {:user_name_valid, false} -> @wrong_arguments_result
      {:currency_valid, false} -> @wrong_arguments_result
      {:amount_valid, false} -> @wrong_arguments_result
      {:user_exists, false, nil} -> @user_does_not_exists_result
      {:queue_full, true} -> @too_many_requests_to_user_result
      {:queue_full, :error} -> @too_many_requests_to_user_result
    end
  end

  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(user, amount, currency) do
    with {:user_name_valid, true} <- {:user_name_valid, valid_string?(user)},
         {:currency_valid, true} <- {:currency_valid, valid_string?(currency)},
         {:amount_valid, true} <- {:amount_valid, valid_number?(amount)},
         {:user_exists, true, found_user} <- check_users_existance(:user_exists, user),
         {:has_enough_money, true} <-
           {:has_enough_money, Structs.User.can_withdraw?(found_user, amount, currency)},
         {:queue_full, false} <- {:queue_full, Structs.User.queue_full?(found_user)},
         new_balance <- Core.update_balance(user, amount * -1, currency) do
      {:ok, new_balance: new_balance}
    else
      {:user_name_valid, false} ->
        @wrong_arguments_result

      {:currency_valid, false} ->
        @wrong_arguments_result

      {:amount_valid, false} ->
        @wrong_arguments_result

      {:user_exists, false, nil} ->
        @user_does_not_exists_result

      {:has_enough_money, false} ->
        @not_enough_money_result

      {:queue_full, true} ->
        @too_many_requests_to_user_result

      {:queue_full, :error} ->
        @too_many_requests_to_user_result
    end
  end

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    with {:user_name_valid, true} <- {:user_name_valid, valid_string?(user)},
         {:currency_valid, true} <- {:currency_valid, valid_string?(currency)},
         {:user_exists, true, found_user} <- check_users_existance(:user_exists, user),
         {:queue_full, false} <- {:queue_full, Structs.User.queue_full?(found_user)},
         balance <- Core.get_balance(user, currency) do
      {:ok, balance: balance}
    else
      {:user_name_valid, false} ->
        @wrong_arguments_result

      {:currency_valid, false} ->
        @wrong_arguments_result

      {:user_exists, false, nil} ->
        @user_does_not_exists_result

      {:queue_full, true} ->
        @too_many_requests_to_user_result

      {:queue_full, :error} ->
        @too_many_requests_to_user_result
    end
  end

  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) ::
          {:ok, from_user_balance :: number, to_user_balance :: number}
          | {:error,
             :wrong_arguments
             | :not_enough_money
             | :sender_does_not_exist
             | :receiver_does_not_exist
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency) do
    with {:from_user_name_valid, true} <- {:from_user_name_valid, valid_string?(from_user)},
         {:to_user_name_valid, true} <- {:to_user_name_valid, valid_string?(to_user)},
         {:currency_valid, true} <- {:currency_valid, valid_string?(currency)},
         {:amount_valid, true} <- {:amount_valid, valid_number?(amount)},
         {:from_user_exists, true, found_from_user} <-
           check_users_existance(:from_user_exists, from_user),
         {:from_user_queue_full, false} <-
           {:from_user_queue_full, Structs.User.queue_full?(found_from_user)},
         {:to_user_exists, true, found_to_user} <-
           check_users_existance(:to_user_exists, to_user),
         {:to_user_queue_full, false} <-
           {:to_user_queue_full, Structs.User.queue_full?(found_to_user)},
         {:has_enough_money, true} <-
           {:has_enough_money, Structs.User.can_withdraw?(found_from_user, amount, currency)},
         new_sender_balance <- Core.update_balance(from_user, amount * -1, currency),
         new_receiver_balance <- Core.update_balance(to_user, amount, currency) do
      {:ok, from_user_balance: new_sender_balance, to_user_balance: new_receiver_balance}
    else
      {:from_user_name_valid, false} -> @wrong_arguments_result
      {:to_user_name_valid, false} -> @wrong_arguments_result
      {:currency_valid, false} -> @wrong_arguments_result
      {:amount_valid, false} -> @wrong_arguments_result
      {:from_user_exists, false, nil} -> {:error, :sender_does_not_exist}
      {:to_user_exists, false, nil} -> {:error, :receiver_does_not_exist}
      {:has_enough_money, false} -> @not_enough_money_result
      {:from_user_queue_full, true} -> {:error, :too_many_requests_to_sender}
      {:to_user_queue_full, true} -> {:error, :too_many_requests_to_receiver}
    end
  end

  @spec check_users_existance(user_atom :: atom(), user_name :: String.t()) ::
          {atom(), true, Structs.User.t()} | {atom(), false, nil}
  defp check_users_existance(user_atom, user_name) do
    with _ <- Core.start_link(user_name),
         found_user <- Core.details(user_name),
         true <- Structs.User.user_exists?(found_user) do
      {user_atom, true, found_user}
    else
      false -> {user_atom, false, nil}
    end
  end
end
