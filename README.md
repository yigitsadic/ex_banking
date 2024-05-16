# ExBanking - Elixir Test

Banking application example with functionality of creating users, getting balances, depositing, withdrawing and sending.

All actions apart from creating a user, requires a load balancing that there won't be more than 10 jobs in queue in any moment, if the queue is full, then they'll respond with `too_many_requests` error.

Since user name is a unique identifier for users, all users have their own process from GenServer with `name_#{user_name}`. GenServer used as state holder and message broker. Every user has it's own process and the state related to user stays in that process, in result every user can access their own data.

In order to implement a load balancing functionality, I created a macro that yields given function and casts `queue_increment` and `queue_decrement` to the related GenServer. I could also use `Process.info()` to access process' mail box count with `message_queue_len` but, I did choose to continue with my implementation.

Also, one requirement was 2 decimal precision of money. In my everyday approach is either store currency amounts in integers with multiplying 100 or handling money amounts with `decimal` type. Displaying and storing floating numbers are not an easy task. To ensure consistency it is a good practise to display them as strings, such as `"15.77"`. Function specs clearly point out that returning values should be `number()` so I didn't use `String.t()` but instead I sanitized each `number()` input after 2 points in decimal place. 

## Code organization

`ExBanking` module has the only wanted functions' delegations. Controller logic lies under `internal` folder.

`Events` is a macro for casting `queue_increment` and `queue_decrement` messages to corresponding processes during an action (like `deposit`).

`Shared` is a module for shared utility functions and error responses. With usage of this, I achieved unified and consistent error responses.

`Formatting` module is to organize formatting function.

`Validators` module organizes validation functions such as `valid_string?` and `valid_number?`.

`Structs/User` module has a struct for user's state as well as functions for accessing user's amount in currency, adding an amount to user, and queue control functions.

`Core` is the module where I used GenServer to store users' states own seperate processes.

Also there are tests for each related module under `tests/` folder. 
To run tests: `mix test`

## Public function specs

```elixir
@spec create_user(user :: String.t) :: :ok | {:error, :wrong_arguments | :user_already_exists}

@spec deposit(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}

@spec withdraw(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :not_enough_money | :too_many_requests_to_user}

@spec get_balance(user :: String.t, currency :: String.t) :: {:ok, balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}

@spec send(from_user :: String.t, to_user :: String.t, amount :: number, currency :: String.t) :: {:ok, from_user_balance :: number, to_user_balance :: number} | {:error, :wrong_arguments | :not_enough_money | :sender_does_not_exist | :receiver_does_not_exist | :too_many_requests_to_sender | :too_many_requests_to_receiver}
```
