defmodule ValidatorsTest do
  use ExUnit.Case

  test "should return true for valid string" do
    assert Validators.valid_string?("Yigit")
  end

  test "valid_string? calling without parameters should return false" do
    assert Validators.valid_string?() == false
  end

  test "calling valid_string? with another type should return false" do
    test_cases = [
      15,
      true,
      %{},
      [],
      nil,
      :atom
    ]

    Enum.each(test_cases, fn inp ->
      assert Validators.valid_string?(inp) == false
    end)
  end

  test "calling valid_string with an empty string should return false" do
    assert Validators.valid_string?("") == false
    assert Validators.valid_string?("  ") == false
  end

  test "should return true for valid number" do
    assert Validators.valid_number?(15)
    assert Validators.valid_number?(15.50)
    assert Validators.valid_number?(0.01)
  end

  test "calling valid_number?() without any arguments should return false" do
    assert Validators.valid_number?() == false
  end

  test "valid_number?() should be called with a number only" do
    test_cases = [
      "15",
      true,
      %{},
      [],
      nil,
      :atom
    ]

    Enum.each(test_cases, fn inp ->
      assert Validators.valid_number?(inp) == false
    end)
  end

  test "calling valid number with a negative or zero should return false" do
    assert Validators.valid_number?(-5) == false
    assert Validators.valid_number?(0) == false
  end
end
