defmodule EyeTestWeb.LocationController do
  use EyeTestWeb, :controller
  alias EyeTest.Data.Location

  plug :ensure_logged_in
  plug :load_location when action in [:show, :edit, :update, :delete]

  def index(conn, _params) do
    locations = Location.all(user: conn.assigns.current_user, order: :name)
    render conn, "index.html", locations: locations
  end

  def new(conn, _params) do
    changeset = Location.new_changeset()
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"location" => location_params}) do
    location_params = Map.put(location_params, "user_id", conn.assigns.current_user.id)

    case Location.insert(location_params) do
      {:ok, location} ->
        conn
        |> put_flash(:info, "Location created.")
        |> redirect(to: Routes.location_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Please see errors below.")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    changeset = Location.changeset(conn.assigns.location)
    render conn, "edit.html", changeset: changeset
  end

  def update(conn, %{"location" => location_params}) do
    case Location.update(conn.assigns.location, location_params) do
      {:ok, location} ->
        conn
        |> put_flash(:info, "Location updated.")
        |> redirect(to: Routes.location_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Please see errors below.")
        |> render("edit.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    Location.delete!(conn.assigns.location)

    conn
    |> put_flash(:info, "Location deleted.")
    |> redirect(to: Routes.location_path(conn, :index))
  end

  #
  # Internal
  #

  defp load_location(conn, _) do
    location = Location.get!(conn.params["id"], user: conn.assigns.current_user)
    assign(conn, :location, location)
  end
end
