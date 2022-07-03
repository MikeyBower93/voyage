defmodule ApolloWeb.HealthController do
  use ApolloWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{healhy: true, node_name: node()})
  end
end
