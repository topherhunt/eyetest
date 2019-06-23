defmodule EyeTestWeb.AssessmentControllerTest do
  use EyeTestWeb.ConnCase, async: true
  alias EyeTestWeb.Data.{}

  describe "plugs" do
    test "most actions reject if no user is logged in", %{conn: conn} do
      conn = get(conn, Routes.assessment_path(conn, :index))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
      assert conn.halted
    end
  end

  describe "#index" do
    test "lists my assessments (but not someone else's)", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      assessment1 = Factory.insert_assessment(user_id: user.id)
      assessment2 = Factory.insert_assessment(user_id: user.id)
      assessment3 = Factory.insert_assessment()

      conn = get(conn, Routes.assessment_path(conn, :index))

      assert conn.resp_body =~ "test-page-assessment-index"
      # raise "TODO: match on more than just the id, maybe the show path url?"
      assert conn.resp_body =~ Routes.assessment_path(conn, :show, assessment1)
      assert conn.resp_body =~ Routes.assessment_path(conn, :show, assessment2)
      assert !(conn.resp_body =~ Routes.assessment_path(conn, :show, assessment3))
    end
  end

  describe "#show" do
    test "shows the results page", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      assessment = Factory.insert_assessment(user_id: user.id)

      conn = get(conn, Routes.assessment_path(conn, :show, assessment))

      assert conn.resp_body =~ "test-page-assessment-#{assessment.id}-results"
    end

    test "raises 404 if this is not my assessment", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)
      assessment = Factory.insert_assessment()

      assert_raise Ecto.NoResultsError, fn ->
        get(conn, Routes.assessment_path(conn, :show, assessment))
      end
    end
  end

  describe "#start" do
    test "renders initial state properly", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      Factory.insert_location(user_id: user.id)

      conn = get(conn, Routes.assessment_path(conn, :start))

      assert conn.resp_body =~ "test-assessment-settings-page"
    end
  end

  describe "#phone" do
    test "renders initial state properly", %{conn: conn} do
      conn = get(conn, Routes.assessment_path(conn, :phone, "abc123"))

      assert conn.resp_body =~ "test-page-phone-connecting"
    end
  end
end
