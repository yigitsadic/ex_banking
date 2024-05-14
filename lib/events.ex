defmodule Events do
  defmacro cast_messages(user_name, do: yield) do
    quote do
      Core.increment_queue_for(unquote(user_name))
      result = unquote(yield)
      Core.decrement_queue_for(unquote(user_name))

      result
    end
  end
end
