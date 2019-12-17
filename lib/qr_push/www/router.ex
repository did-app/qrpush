defmodule QrPush.WWW.Router do
  use Raxx.Router
  alias QrPush.WWW.Actions

  section [{Raxx.Logger, Raxx.Logger.setup(level: :info)}], [
    {%{path: []}, Actions.HomePage},
  ]

  section [{Raxx.Logger, Raxx.Logger.setup(level: :debug)}], [
    {_, Actions.NotFoundPage}
  ]
end
