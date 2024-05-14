defmodule Validators do
  @moduledoc "Contains shared validators such as string validation."

  @doc """
  Validates given string.
  Should be a string.
  Should not be empty.
  """
  @spec valid_string?(input :: String.t()) :: boolean()
  def valid_string?(input) when is_bitstring(input) do
    input |> String.trim() != ""
  end

  @spec valid_string?(_input :: any()) :: false
  def valid_string?(_input), do: false

  @spec valid_string?() :: false
  def valid_string?(), do: false

  @doc """
  Validates given number.
  Should be a number.
  Should be positive.
  """
  @spec valid_number?(input :: number()) :: boolean()
  def valid_number?(input) when is_number(input) do
    input > 0
  end

  @spec valid_number?(_input :: any()) :: false
  def valid_number?(_input), do: false

  @spec valid_number?() :: false
  def valid_number?(), do: false
end
