defmodule EyeTestWeb.LocationControllerTest do
  use EyeTestWeb.ConnCase, async: true
  alias EyeTest.Data.Location

  describe "plugs" do
    test "all actions reject if no user is logged in", %{conn: conn} do
      conn = get(conn, Routes.location_path(conn, :index))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
      assert conn.halted
    end
  end

  describe "#index" do
    test "lists all my locations (but not others')", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      location1 = Factory.insert_location(user_id: user.id)
      location2 = Factory.insert_location(user_id: user.id)
      location3 = Factory.insert_location()

      conn = get(conn, Routes.location_path(conn, :index))

      assert conn.resp_body =~ "test-page-location-index"
      assert conn.resp_body =~ location1.name
      assert conn.resp_body =~ location2.name
      assert !(conn.resp_body =~ location3.name)
    end
  end

  describe "#new" do
    test "renders correctly", %{conn: conn} do
      {conn, _} = login_as_new_user(conn)

      conn = get(conn, Routes.location_path(conn, :new))

      assert conn.resp_body =~ "test-page-location-new"
    end
  end

  describe "#create" do
    test "inserts the location and redirects to the list", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)

      params = %{"location" => %{"name" => "Office back wall", "cm_from_screen" => 150}}
      conn = post(conn, Routes.location_path(conn, :create), params)

      location = Location.first(user: user)
      assert location != nil
      assert location.name == "Office back wall"
      assert redirected_to(conn) == Routes.location_path(conn, :index)
    end

    test "rejects changes if invalid", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)
      old_count = Location.count()

      params = %{"location" => %{"name" => " ", "cm_from_screen" => 150}}
      conn = post(conn, Routes.location_path(conn, :create), params)

      assert Location.count() == old_count
      assert html_response(conn, 200) =~ "name can't be blank"
    end
  end

  describe "#edit" do
    test "renders correctly", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      location = Factory.insert_location(user_id: user.id)

      conn = get(conn, Routes.location_path(conn, :edit, location))

      assert conn.resp_body =~ "test-page-location-edit-#{location.id}"
    end

    test "rejects if not location owner", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)
      location = Factory.insert_location()

      assert_raise Ecto.NoResultsError, fn ->
        get(conn, Routes.location_path(conn, :edit, location))
      end
    end
  end

  describe "#update" do
    test "saves changes and redirects", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      location = Factory.insert_location(user_id: user.id)

      params = %{"location" => %{"name" => "New name"}}
      conn = patch(conn, Routes.location_path(conn, :update, location), params)

      assert Location.get!(location.id).name == "New name"
      assert redirected_to(conn) == Routes.location_path(conn, :index)
    end

    test "rejects changes if invalid", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      location = Factory.insert_location(user_id: user.id)

      params = %{"location" => %{"name" => " "}}
      conn = patch(conn, Routes.location_path(conn, :update, location), params)

      assert Location.get!(location.id).name == location.name
      assert html_response(conn, 200) =~ "name can't be blank"
    end

    test "404 if not location owner", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)
      location = Factory.insert_location()
      params = %{"location" => %{"name" => "New name"}}

      assert_raise Ecto.NoResultsError, fn ->
        patch(conn, Routes.location_path(conn, :update, location), params)
      end
    end
  end

  describe "#delete" do
    test "deletes the location", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      location = Factory.insert_location(user_id: user.id)

      conn = delete(conn, Routes.location_path(conn, :delete, location))

      assert Location.count(id: location.id) == 0
      assert redirected_to(conn) == Routes.location_path(conn, :index)
    end

    test "404 if not location owner", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)
      location = Factory.insert_location()

      assert_raise Ecto.NoResultsError, fn ->
        delete(conn, Routes.location_path(conn, :delete, location))
      end

      assert Location.count(id: location.id) == 1
    end
  end
end
