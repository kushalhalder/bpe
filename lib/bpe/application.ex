defmodule Bpe.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Bpe.Repo,
      # Start the endpoint when the application starts
      BpeWeb.Endpoint,
      # Starts a worker by calling: Bpe.Worker.start_link(arg)
      # {Bpe.Worker, arg},
      {Bpe.Connectors.Redix, {"redis://localhost:6379", [name: :redix]}},
      Bpe.TaskDemandHandling.Producer,
      {DynamicSupervisor, strategy: :one_for_one, name: Bpe.DynamicSupervisor},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bpe.Supervisor]

    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BpeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
