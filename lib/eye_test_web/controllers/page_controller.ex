defmodule EyeTestWeb.PageController do
  use EyeTestWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
