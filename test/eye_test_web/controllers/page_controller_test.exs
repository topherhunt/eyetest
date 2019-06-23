defmodule EyeTestWeb.PageControllerTest do
  use EyeTestWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Eye Test"
  end
end
