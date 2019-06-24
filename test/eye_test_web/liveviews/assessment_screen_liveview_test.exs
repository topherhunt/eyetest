defmodule EyeTestWeb.AssessmentScreenLiveviewTest do
  use EyeTestWeb.ConnCase
  # Docs: https://github.com/phoenixframework/phoenix_live_view/blob/master/lib/phoenix_live_view/test/live_view_test.ex
  import Phoenix.LiveViewTest

  defp assessment_params(location) do
    %{
      "location_id" => location.id,
      "which_eye" => "left",
      "current_light_level" => 4,
      "personal_notes" => "test personal note field"
    }
  end

  defp get_displayed_letter(lv) do
    html = render(lv)

    case Regex.run(~r/data-test-letter="(\w)"/, html) do
      nil -> raise("Can't find displayed letter. The full html: #{html}")
      matches -> Enum.at(matches, 1)
    end
  end

  defp message_and_response(lv, msg, expected_html) do
    send(lv.pid, msg)
    html = render(lv)
    assert html =~ expected_html
    html
  end

  test "full normal workflow of an assessment", %{conn: conn} do
    user = Factory.insert_user()
    location = Factory.insert_location(user_id: user.id)
    conn = assign(conn, :current_user, user)

    {:ok, lv, html} = live(conn, "/assessments/start")
    assert html =~ "test-assessment-settings-page"

    # Settings form is submitted (invalid)
    invalid_params = Map.put(assessment_params(location), "which_eye", nil)
    html = render_submit(lv, "submit_settings", %{"assessment" => invalid_params})
    assert html =~ "test-assessment-settings-page"
    assert html =~ "which_eye can't be blank"

    # Settings form is submitted (valid)
    valid_params = assessment_params(location)
    html = render_submit(lv, "submit_settings", %{"assessment" => valid_params})
    assert html =~ "test-assessment-connect-phone-page"

    # Phone connects successfully
    message_and_response(lv, "phone_connected", "test-assessment-get-ready-page")

    # "Start" button clicked on phone
    message_and_response(lv, "start_test", "test-assessment-question-reveal")

    # Correct button pressed (1 correct)
    message_and_response(lv, {"button_pressed", get_displayed_letter(lv)}, "result-correct")
    message_and_response(lv, "next_question", "question-reveal")

    # Correct button pressed (2 correct)
    message_and_response(lv, {"button_pressed", get_displayed_letter(lv)}, "result-correct")
    message_and_response(lv, "next_question", "question-reveal")

    # Incorrect button pressed (1 incorrect)
    message_and_response(lv, {"button_pressed", "wrong"}, "result-incorrect")
    message_and_response(lv, "next_question", "question-reveal")

    # Correct button pressed (3 correct)
    message_and_response(lv, {"button_pressed", get_displayed_letter(lv)}, "result-correct")
    message_and_response(lv, "next_question", "question-reveal")

    # Correct button pressed (4 correct)
    message_and_response(lv, {"button_pressed", get_displayed_letter(lv)}, "result-correct")
    message_and_response(lv, "next_question", "question-reveal")

    # Incorrect button pressed (2 incorrect)
    message_and_response(lv, {"button_pressed", "wrong"}, "result-incorrect")
    message_and_response(lv, "next_question", "question-reveal")

    # Incorrect button pressed (3 incorrect)
    message_and_response(lv, {"button_pressed", "wrong"}, "result-incorrect")
    message_and_response(lv, "next_question", "question-reveal")

    # Incorrect button pressed (4 incorrect)
    message_and_response(lv, {"button_pressed", "wrong"}, "result-incorrect")
    message_and_response(lv, "next_question", "question-reveal")

    # Incorrect button pressed (5 incorrect)
    # After 5 incorrect answers or timeouts, assessment completes and computes scores.
    message_and_response(lv, {"button_pressed", "wrong"}, "result-incorrect")
    message_and_response(lv, "next_question", "test-assessment-done-page")

    # The assessment was persisted
    assert EyeTest.Data.Assessment.count(user: user) == 1
  end
end
