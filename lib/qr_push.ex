defmodule QrPush do
  def welcome_message(name, greeting \\ "Hello")

  def welcome_message(nil, _greeting) do
    nil
  end

  def welcome_message(name, greeting) do
    "#{greeting}, #{name}!"
  end
end
