defmodule FormattingTest do
  use ExUnit.Case

  test "should format with 2 decimal points precision" do
    assert Formatting.format_float(15.33333335) == 15.33
    assert Formatting.format_float(15) == 15.0
    assert Formatting.format_float(13.0123456) == 13.01
    assert Formatting.format_float(13.213456) == 13.21
  end
end
