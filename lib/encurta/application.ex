defmodule Encurta.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EncurtaWeb.Telemetry,
      Encurta.Repo,
      {DNSCluster, query: Application.get_env(:encurta, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Encurta.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Encurta.Finch},
      # Start a worker by calling: Encurta.Worker.start_link(arg)
      # {Encurta.Worker, arg},
      # Start to serve requests, typically the last entry
      EncurtaWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Encurta.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EncurtaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
