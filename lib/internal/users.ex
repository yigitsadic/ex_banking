defmodule Internal.Users do
  import Validators
  import Shared

  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) do
    with true <- all_valid?([{user, &valid_string?/1}]),
         {:user_exists, false, _} <- check_users_existance(:user_exists, user),
         _ <- Core.create_user(user) do
      :ok
    else
      false -> wrong_arguments_result()
      {:user_exists, true, _} -> user_already_exists()
    end
  end
end
