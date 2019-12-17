defmodule QrPush.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    cleartext_options = [port: port(), cleartext: true]

    secure_options = [
      port: secure_port(),
      certfile: certificate_path(),
      keyfile: certificate_key_path()
    ]

    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: QrPush.MailboxSupervisor},
      QrPush.Counter,
      {QrPush.WWW, [cleartext_options]},
      {QrPush.WWW, [secure_options]},
      Supervisor.child_spec(
        {Task, fn -> System.cmd("npm", ["run", "watch:js"], cd: "lib/qr_push/www") end},
        id: :watch_js
      ),
      Supervisor.child_spec(
        {Task, fn -> System.cmd("npm", ["run", "watch:css"], cd: "lib/qr_push/www") end},
        id: :watch_css
      )
    ]

    opts = [strategy: :one_for_one, name: QrPush.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp port() do
    with raw when is_binary(raw) <- System.get_env("PORT"), {port, ""} = Integer.parse(raw) do
      port
    else
      _ -> 8080
    end
  end

  defp secure_port() do
    with raw when is_binary(raw) <- System.get_env("SECURE_PORT"),
         {secure_port, ""} = Integer.parse(raw) do
      secure_port
    else
      _ -> 8443
    end
  end

  defp certificate_path() do
    Application.app_dir(:qr_push, "priv/localhost/certificate.pem")
  end

  defp certificate_key_path() do
    Application.app_dir(:qr_push, "priv/localhost/certificate_key.pem")
  end
end
