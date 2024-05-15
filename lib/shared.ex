defmodule Shared do
  @spec wrong_arguments_result() :: {:error, :wrong_arguments}
  def wrong_arguments_result(), do: {:error, :wrong_arguments}

  @spec not_enough_money_result() :: {:error, :not_enough_money}
  def not_enough_money_result(), do: {:error, :not_enough_money}

  @spec user_already_exists() :: {:error, :user_already_exists}
  def user_already_exists(), do: {:error, :user_already_exists}

  @spec user_does_not_exists_result() ::
          {:error, :receiver_does_not_exist | :sender_does_not_exist | :user_does_not_exist}
  def user_does_not_exists_result(user_type \\ :default) do
    case user_type do
      :sender -> {:error, :sender_does_not_exist}
      :receiver -> {:error, :receiver_does_not_exist}
      _ -> {:error, :user_does_not_exist}
    end
  end

  @spec too_many_requests_to_user_result() ::
          {:error,
           :too_many_requests_to_receiver
           | :too_many_requests_to_sender
           | :too_many_requests_to_user}
  def too_many_requests_to_user_result(user_type \\ :default) do
    case user_type do
      :sender -> {:error, :too_many_requests_to_sender}
      :receiver -> {:error, :too_many_requests_to_receiver}
      _ -> {:error, :too_many_requests_to_user}
    end
  end

  @doc "Checks user exist in GenServer."
  @spec check_users_existance(user_atom :: atom(), user_name :: String.t()) ::
          {atom(), true, Structs.User.t()} | {atom(), false, nil}
  def check_users_existance(user_atom, user_name) do
    with _ <- Core.start_link(user_name),
         found_user <- Core.details(user_name),
         true <- Structs.User.user_exists?(found_user) do
      {user_atom, true, found_user}
    else
      false -> {user_atom, false, nil}
    end
  end
end
