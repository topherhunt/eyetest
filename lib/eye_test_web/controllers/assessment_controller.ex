defmodule EyeTestWeb.AssessmentController do
  use EyeTestWeb, :controller
  alias EyeTest.Data.Assessment

  plug :ensure_logged_in when action in [:index, :show, :start]
  plug :load_assessment when action in [:show]
  plug :ensure_at_least_one_location when action in [:start]

  # list the assmts I've taken (possibly filtered)
  def index(conn, _params) do
    # TODO: support filtering. Make this a LV, that would be cool.
    assessments = Assessment.all(user: conn.assigns.current_user, order: :started_at_desc)
    render conn, "index.html", assessments: assessments
  end

  def show(conn, _params) do
    render conn, "show.html"
  end

  def start(conn, _params) do
    session = %{user: conn.assigns.current_user}
    live_render(conn, EyeTest.AssessmentScreenLiveview, session: session)
  end

  def phone(conn, params) do
    session = %{assessment_uuid: params["assessment_uuid"]}
    live_render(conn, EyeTest.AssessmentPhoneLiveview, session: session)
  end

  #
  # Helpers
  #

  defp load_assessment(conn, _) do
    assessment = Assessment.get!(conn.params["id"], user: conn.assigns.current_user, preload: :location)
    assign(conn, :assessment, assessment)
  end

  defp ensure_at_least_one_location(conn, _opts) do
    if EyeTest.Data.Location.count(user: conn.assigns.current_user) > 0 do
      conn
    else
      conn
      |> put_flash(:error, "To run a test, please first set up a location.")
      |> redirect(to: Routes.location_path(conn, :new))
      |> halt()
    end
  end
end
