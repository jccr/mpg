defmodule MpgWeb.PageController do
  use MpgWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
