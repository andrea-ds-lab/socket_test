defmodule SocketTest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SocketTestWeb.Telemetry,
      SocketTest.Repo,
      {DNSCluster, query: Application.get_env(:socket_test, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SocketTest.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SocketTest.Finch},
      # Start a worker by calling: SocketTest.Worker.start_link(arg)
      # {SocketTest.Worker, arg},
      # Start to serve requests, typically the last entry
      SocketTestWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SocketTest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SocketTestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
