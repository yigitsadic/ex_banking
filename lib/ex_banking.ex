defmodule ExBanking do
  defdelegate create_user(user), to: Internal.Users
  defdelegate deposit(user, amount, currency), to: Internal.Deposits
  defdelegate withdraw(user, amount, currency), to: Internal.Withdrawals
  defdelegate get_balance(user, currency), to: Internal.Balance
  defdelegate send(from_user, to_user, amount, currency), to: Internal.Transfers
end
