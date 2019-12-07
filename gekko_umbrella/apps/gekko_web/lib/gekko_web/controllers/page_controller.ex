defmodule GekkoWeb.PageController do
  use GekkoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
