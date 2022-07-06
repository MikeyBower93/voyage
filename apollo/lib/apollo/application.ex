defmodule Apollo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = [
      apollo: [
        strategy: Cluster.Strategy.DNSPoll,
        config: [
          polling_interval: 1000,
          query: "apollo.apollo.local",
          node_basename: "apollo"
        ]
      ]
    ]

    children = [
      # Start the Ecto repository
      Apollo.Repo,
      {Cluster.Supervisor, [topologies, [name: Apollo.ClusterSupervisor]]},
      # Start the Telemetry supervisor
      ApolloWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Apollo.PubSub},
      # Start the Endpoint (http/https)
      ApolloWeb.Endpoint
      # Start a worker by calling: Apollo.Worker.start_link(arg)
      # {Apollo.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Apollo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ApolloWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
