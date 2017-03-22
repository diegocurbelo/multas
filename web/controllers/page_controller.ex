defmodule Multas.PageController do
  use Multas.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
