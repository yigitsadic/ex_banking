defmodule Internal.Balance do
  import Validators
  import Shared

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    with {:params_valid, true} <-
           {:params_valid,
            all_valid?([
              {user, &valid_string?/1},
              {currency, &valid_string?/1}
            ])},
         {:user_exists, true, found_user} <- check_users_existance(:user_exists, user),
         {:queue_full, false} <- {:queue_full, Structs.User.queue_full?(found_user)},
         balance <- Core.get_balance(user, currency) do
      {:ok, balance: balance}
    else
      {:params_valid, false} ->
        wrong_arguments_result()

      {:user_exists, false, nil} ->
        user_does_not_exists_result()

      {:queue_full, _} ->
        too_many_requests_to_user_result()
    end
  end
end
