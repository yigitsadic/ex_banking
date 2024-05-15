defmodule Formatting do
  @doc "Formats given number with 2 decimal precision."
  @spec format_float(num :: number()) :: number()
  def format_float(num) do
    :erlang.trunc(num * 100) / 100
  end
end
