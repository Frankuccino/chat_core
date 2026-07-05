defmodule ChatCore.MixProject do
  use Mix.Project

  def project do
    [
      app: :chat_core,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # OTP application config. `mod:` tells the VM which module boots first 
  # (like main() in Go, or fn main() in Rust) - except here what boots
  # is a *supervisor*, not just a function.
  def application do
    [
      extra_applications: [:logger],
      mod: {ChatCore.Application, []}
    ]
  end

  defp deps do
    []
  end
end
