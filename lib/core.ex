defmodule Core do
  @moduledoc """
  Core module for handling GenServer calls and implementations.

  Each user will have it's own named process doing state management.
  """

  use GenServer
  alias Structs.User
  require Events

  # Client side

  @doc "Creates a new user with given users name using sync call."
  def create_user(user_name) do
    GenServer.call(server_name_for(user_name), {:create, user_name})
  end

  @doc "Fetches details of user with given name."
  def details(user_name) do
    GenServer.call(server_name_for(user_name), :details)
  end

  @doc "Fetches requested balance in currency."
  def get_balance(user_name, currency) do
    Events.cast_messages user_name do
      user = GenServer.call(server_name_for(user_name), :get_balance)
      User.get_currency(user, currency)
    end
  end

  @doc "Appends given amount in currency to requested user's balance."
  def update_balance(user_name, amount, currency) do
    Events.cast_messages user_name do
      GenServer.call(server_name_for(user_name), {:update_balance, amount, currency})
    end
  end

  @doc "Adds a job to the queue."
  def increment_queue_for(user_name) do
    GenServer.cast(server_name_for(user_name), :queue_increment)
  end

  @doc "Removes a job from the queue."
  def decrement_queue_for(user_name) do
    GenServer.cast(server_name_for(user_name), :queue_decrement)
  end

  @doc "Returns unique server name for user."
  @spec server_name_for(user_name :: String.t()) :: {:global, String.t()}
  def server_name_for(user_name) when is_bitstring(user_name) do
    {:global, "user_#{user_name}"}
  end

  @doc "Fires a new process named with given user's name."
  def start_link(user_name) do
    GenServer.start_link(__MODULE__, %{}, name: server_name_for(user_name))
  end

  # Server side implementations.

  @impl true
  def init(user) do
    {:ok, user}
  end

  # Serves create user call. Fills `Structs.User` with given user name.
  @impl true
  def handle_call({:create, user_name}, _from, _state) do
    newState = User.new(user_name)

    {:reply, newState, newState}
  end

  # Fetches details of given name.
  @impl true
  def handle_call(:details, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:get_balance, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:update_balance, amount, currency}, _from, state) do
    new_state = User.add_currency(state, amount, currency)

    {:reply, User.get_currency(new_state, currency), new_state}
  end

  # Increments job queue by 1.
  @impl true
  def handle_cast(:queue_increment, state) do
    {:noreply, User.increment_queue(state)}
  end

  # Decrement job queue by 1.
  @impl true
  def handle_cast(:queue_decrement, state) do
    {:noreply, User.decrement_queue(state)}
  end
end
