defmodule ThreadneedleWeb.PageController do
  use ThreadneedleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
