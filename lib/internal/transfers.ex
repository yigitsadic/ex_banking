defmodule Internal.Transfers do
  import Validators
  import Shared

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
    with {:params_valid, true} <-
           {:params_valid,
            all_valid?([
              {from_user, &valid_string?/1},
              {to_user, &valid_string?/1},
              {currency, &valid_string?/1},
              {amount, &valid_number?/1}
            ])},
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
      {:params_valid, false} -> wrong_arguments_result()
      {:from_user_exists, false, nil} -> user_does_not_exists_result(:sender)
      {:to_user_exists, false, nil} -> user_does_not_exists_result(:receiver)
      {:has_enough_money, false} -> not_enough_money_result()
      {:from_user_queue_full, true} -> too_many_requests_to_user_result(:sender)
      {:to_user_queue_full, true} -> too_many_requests_to_user_result(:receiver)
    end
  end
end
