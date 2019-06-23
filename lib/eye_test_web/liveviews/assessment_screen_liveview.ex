defmodule EyeTest.AssessmentScreenLiveview do
  use Phoenix.LiveView
  alias EyeTest.Data.Assessment
  require Logger

  def mount(session, socket) do
    assessment = %Assessment{
      user: session.user,
      user_id: session.user.id,
      # A random string used to pair the screen <--> phone. Won't be persisted.
      uuid: EyeTest.Factory.random_uuid() |> String.downcase()
    }

    # This is a complete list of assigns used in this LV.
    initial_state = %{
      # An in-memory copy of the assessment we're running. Not persisted until the end.
      assessment: assessment,
      # All steps: ["settings", "connect_phone", "get_ready", "questions", "complete"]
      step: "settings",
      # For the settings page
      settings_changeset: Assessment.settings_changeset(assessment),
      # For the settings page
      all_locations: EyeTest.Data.Location.all(user: assessment.user, order: :name),
      # All questions we've gone through so far. Will eventually be saved to the assessment.
      questions: [],
      # The question we're currently presenting
      this_question: nil
    }

    socket = assign(socket, initial_state)

    if connected?(socket) do
      log socket, "Initialized."
      subscribe(socket)
    end

    {:ok, socket}
  end

  def render(assigns) do
    EyeTestWeb.AssessmentView.render("screen.html", assigns)
  end

  #
  # Messages from client
  #

  def handle_event("submit_settings" = msg, params, socket) do
    log socket, "Received msg #{inspect(msg)} with params: #{inspect(params)}"

    changeset =
      Assessment.settings_changeset(socket.assigns.assessment, params["assessment"])
      |> Map.put(:action, :insert)

    if changeset.valid? do
      # Update the in-memory Assessment struct, but don't save it yet
      assessment = Map.merge(socket.assigns.assessment, changeset.changes)
      {:noreply, assign(socket, %{assessment: assessment, step: "connect_phone"})}
    else
      {:noreply, assign(socket, %{settings_changeset: changeset})}
    end
  end

  #
  # Messages from server-side
  #

  def handle_info("phone_connected" = msg, socket) do
    if socket.assigns.step == "connect_phone" do
      log socket, "Received msg #{inspect(msg)}."
      broadcast_to_phone(socket, {"display", "get_ready"})
      {:noreply, assign(socket, :step, "get_ready")}
    else
      # This might mean the phone lost then re-gained connection.
      log socket, "Ignoring duplicate phone_connected msg."
      {:noreply, socket}
    end
  end

  def handle_info("start_test" = msg, socket) do
    log socket, "Received msg #{inspect(msg)}."
    {:noreply, start_assessment(socket)}
  end

  def handle_info("reveal_question" = msg, socket) do
    log socket, "Received msg #{inspect(msg)}."
    this_question = socket.assigns.this_question |> Map.put(:step, "reveal")

    broadcast_to_phone(socket, {"display", "letter_buttons"})
    :timer.send_after(5000, self(), {"question_timed_out", this_question.uuid})
    {:noreply, assign(socket, :this_question, this_question)}
  end

  def handle_info({"button_pressed", guess} = msg, socket) do
    log socket, "Received msg #{inspect(msg)}."
    {:noreply, handle_question_response(socket, guess)}
  end

  def handle_info({"question_timed_out", uuid} = msg, socket) do
    if uuid == socket.assigns.this_question.uuid do
      log socket, "Received msg #{inspect(msg)}. Question time expired."
      {:noreply, handle_question_response(socket, "")}
    else
      log socket, "Received msg #{inspect(msg)}. Ignoring."
      {:noreply, socket}
    end
  end

  def handle_info("next_question" = msg, socket) do
    log socket, "Received msg #{inspect(msg)}."

    this_question = Map.drop(socket.assigns.this_question, [:step, :uuid])
    questions = socket.assigns.questions ++ [this_question]
    socket = assign(socket, :questions, questions)
    log socket, "Completed questions so far: #{inspect(questions)}"

    if test_should_continue?(socket) do
      {:noreply, prep_this_question(socket)}
    else
      assessment = complete_assessment(socket)
      broadcast_to_phone(socket, {"display", "done"})
      {:noreply, assign(socket, %{assessment: assessment, step: "complete"})}
    end
  end

  #
  # Helpers
  #

  defp log(socket, msg) do
    uuid = socket.assigns.assessment.uuid
    Logger.info "AssessmentScreenLiveview (uuid #{uuid}): #{msg}"
  end

  defp subscribe(socket) do
    channel = "assessment.#{socket.assigns.assessment.uuid}.screen"
    Phoenix.PubSub.subscribe(EyeTest.PubSub, channel)
  end

  defp broadcast_to_phone(socket, event) do
    channel = "assessment.#{socket.assigns.assessment.uuid}.phone"
    Phoenix.PubSub.broadcast(EyeTest.PubSub, channel, event)
  end

  #
  # Assessment workflow
  #

  def start_assessment(socket) do
    assessment = Map.put(socket.assigns.assessment, :started_at, Timex.now())

    socket
    |> assign(:assessment, assessment)
    |> assign(:step, "questions")
    |> prep_this_question()
  end

  defp prep_this_question(socket) do
    question = generate_question(socket)
    broadcast_to_phone(socket, {"display", "countdown"})
    :timer.send_after(100, self(), "reveal_question")
    assign(socket, %{this_question: question})
  end

  defp generate_question(socket) do
    last_q = List.last(socket.assigns.questions) || %{size: 100.0, correct: false}
    size = if last_q.correct, do: last_q.size * 0.95, else: last_q.size
    size = Float.round(size, 2)
    actual = random_letter()
    uuid = EyeTest.Factory.random_uuid()
    %{uuid: uuid, size: size, actual: actual, step: "countdown"}
  end

  defp random_letter do
    # I'm using 9 letters like the Snellen chart, but replacing C with S.
    # I could also use a larger pool if I want more entropy: ABCDFGHJKLMNPQRSTUVWXYZ
    Enum.random(~w(D E F L O P S T Z))
  end

  defp handle_question_response(socket, guess) do
    this_question = record_answer(socket.assigns.this_question, guess)

    broadcast_to_phone(socket, {"display", "blank"})
    :timer.send_after(500, self(), "next_question")
    assign(socket, :this_question, this_question)
  end

  defp record_answer(question, guess) do
    question
    |> Map.put(:guess, guess)
    |> Map.put(:correct, guess == question.actual)
    |> Map.put(:step, "result")
  end

  defp test_should_continue?(socket) do
    questions = socket.assigns.questions
    num_false = Enum.count(questions, fn(q) -> q.correct == false end)
    num_false < 5
  end

  defp complete_assessment(socket) do
    socket.assigns.assessment
    |> Map.put(:completed_at, Timex.now())
    |> Map.put(:questions, socket.assigns.questions)
    |> EyeTest.Data.compute_scores()
    |> Map.from_struct()
    |> Assessment.insert!()
  end
end
