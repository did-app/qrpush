defmodule QrPush.Mixfile do
  use Mix.Project

  def project do
    [
      app: :qr_push,
      version: "0.1.0",
      elixir: "~> 1.10",
      erlc_paths: ["src", "gen"],
      compilers: [:gleam | Mix.compilers()],
      # aliases: [
      #   "compile.gleam": fn _ ->
      #     System.cmd("gleam", ["build"])
      #     :ok
      #   end
      # ],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {:qr_push@application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_gleam, "~> 0.1.0"},
      # {:gleam_stdlib, "~> 0.9.0"}
      {:gleam_stdlib, github: "gleam-lang/stdlib", manager: :rebar3, override: true},
      {:base32, "~> 0.1.0"},
      {:midas, github: "midas-framework/midas", manager: :rebar3}
    ]
  end
end
