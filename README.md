# ExBanking - Elixir Test

Banking application example with functionality of creating users, getting balances, depositing, withdrawing and sending.

All actions apart from creating a user, requires a load balancing that there won't be more than 10 jobs in queue in any moment, if the queue is full, then they'll respond with `too_many_requests` error.

All users have their own process from GenServer. GenServer used as state holder and message broker. Every user has it's own process and the state related to user stays in that process, in result every user can access their own data.

In order to implement a load balancing functionality, I created a macro that yields given function and casts `queue_increment` and `queue_decrement` to the related GenServer. 

Also, one requirement was 2 decimal precision of money. In my everyday approach is either store currency amounts in integers with multiplying 100 or handling money amounts with `decimal` type. Displaying and storing floating numbers are not an easy task. To ensure consistency it is a good practise to display them as strings, such as `"15.77"`. Function specs clearly point out that returning values should be `number()` so I didn't use `String.t()` but instead I sanitized each `number()` input after 2 points in decimal place. 

To run tests: `mix test`

## Public function specs

```elixir
@spec create_user(user :: String.t) :: :ok | {:error, :wrong_arguments | :user_already_exists}

@spec deposit(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}

@spec withdraw(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :not_enough_money | :too_many_requests_to_user}

@spec get_balance(user :: String.t, currency :: String.t) :: {:ok, balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}

@spec send(from_user :: String.t, to_user :: String.t, amount :: number, currency :: String.t) :: {:ok, from_user_balance :: number, to_user_balance :: number} | {:error, :wrong_arguments | :not_enough_money | :sender_does_not_exist | :receiver_does_not_exist | :too_many_requests_to_sender | :too_many_requests_to_receiver}
```
