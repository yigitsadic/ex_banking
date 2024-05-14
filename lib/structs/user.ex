defmodule Structs.User do
  @max_event_queue 10
  @enforce_keys :username
  defstruct username: "", currencies: %{}, event_queue: 0

  @type currency_map :: %{String.t() => number()}

  @type t :: %__MODULE__{
          username: String.t(),
          currencies: currency_map(),
          event_queue: number()
        }

  @doc "Gets requested currency from user."
  @spec get_currency(user :: t(), currency :: String.t()) :: number()
  def get_currency(user, currency) when is_map(user) and is_bitstring(currency) do
    Map.get(user.currencies, currency) || 0
  end

  @doc "Adds given amount in currency to requested user."
  @spec add_currency(user :: t(), amount :: number(), currency :: String.t()) :: t()
  def add_currency(user, amount, currency)
      when is_map(user) and is_number(amount) and is_bitstring(currency) do
    new_amount = get_currency(user, currency) + amount

    currencies = user.currencies
    updated_currencies = Map.put(currencies, currency, new_amount)

    new_user = Map.put(user, :currencies, updated_currencies)

    new_user
  end

  @doc "Checks that given user can withdraw amount in currency."
  @spec can_withdraw?(user :: t(), amount :: number(), currency :: String.t()) :: boolean()
  def can_withdraw?(user, amount, currency) do
    current_amount = get_currency(user, currency)

    current_amount >= amount
  end

  @doc "Checks if given users event queue is full."
  @spec queue_full?(user :: t()) :: {:ok, boolean()} | {:error}
  def queue_full?(user) when is_map(user) do
    if :event_queue in Map.keys(user) do
      {:ok, Map.get(user, :event_queue, 0) >= @max_event_queue}
    else
      {:error}
    end
  end

  @spec queue_full?(_user :: any()) :: {:error}
  def queue_full?(_user), do: {:error}

  @doc "Returns queue incremented user."
  @spec increment_queue(user :: t()) :: t()
  def increment_queue(user) do
    Map.put(user, :event_queue, user.event_queue + 1)
  end

  @doc "Returns queue decremented user. Minimum value will always be 0."
  @spec decrement_queue(user :: t()) :: t()
  def decrement_queue(user) do
    Map.put(user, :event_queue, max(0, user.event_queue - 1))
  end

  @spec user_exists?(user :: map()) :: boolean()
  def user_exists?(user) do
    Map.get(user, :username, "") != ""
  end

  @doc "Returns a struct filled with given name"
  @spec new(name :: String.t()) :: t()
  def new(name) when is_bitstring(name) do
    %__MODULE__{
      username: name
    }
  end
end
