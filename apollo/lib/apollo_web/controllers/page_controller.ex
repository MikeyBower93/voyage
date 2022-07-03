defmodule ApolloWeb.PageController do
  use ApolloWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
