defmodule Internal.Withdrawals do
  import Validators
  import Shared

  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(user, amount, currency) do
    with {:params_valid, true} <-
           {:params_valid,
            all_valid?([
              {user, &valid_string?/1},
              {currency, &valid_string?/1},
              {amount, &valid_number?/1}
            ])},
         {:user_exists, true, found_user} <- check_users_existance(:user_exists, user),
         {:has_enough_money, true} <-
           {:has_enough_money, Structs.User.can_withdraw?(found_user, amount, currency)},
         {:queue_full, false} <- {:queue_full, Structs.User.queue_full?(found_user)},
         new_balance <- Core.update_balance(user, amount * -1, currency) do
      {:ok, new_balance: new_balance}
    else
      {:params_valid, false} ->
        wrong_arguments_result()

      {:user_exists, false, nil} ->
        user_does_not_exists_result()

      {:has_enough_money, false} ->
        not_enough_money_result()

      {:queue_full, _} ->
        too_many_requests_to_user_result()
    end
  end
end
