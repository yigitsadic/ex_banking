defmodule Core do
  @moduledoc """
  Core module for handling GenServer calls and implementations.

  Each user will have it's own named process doing state management.
  """

  use GenServer
  alias Structs.User

  # Client side

  @doc "Creates a new user with given users name using sync call."
  def create_user(user_name) do
    GenServer.call({:global, "user_#{user_name}"}, {:create, user_name})
  end

  @doc "Fetches details of user with given name."
  def details(user_name) do
    GenServer.call({:global, "user_#{user_name}"}, :details)
  end

  @doc "Fires a new process named with given user's name."
  def start_link(user_name) do
    GenServer.start_link(__MODULE__, %{}, name: {:global, "user_#{user_name}"})
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
end
