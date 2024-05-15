defmodule Internal.Deposits do
  import Validators
  import Shared

  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) do
    with {:params_valid, true} <-
           {:params_valid,
            all_valid?([
              {user, &valid_string?/1},
              {currency, &valid_string?/1},
              {amount, &valid_number?/1}
            ])},
         {:user_exists, true, found_user} <- check_users_existance(:user_exists, user),
         {:queue_full, false} <- {:queue_full, Structs.User.queue_full?(found_user)},
         new_balance <- Core.update_balance(user, amount, currency) do
      {:ok, new_balance: new_balance}
    else
      {:params_valid, false} -> wrong_arguments_result()
      {:user_exists, false, _} -> user_does_not_exists_result()
      {:queue_full, _} -> too_many_requests_to_user_result()
    end
  end
end
