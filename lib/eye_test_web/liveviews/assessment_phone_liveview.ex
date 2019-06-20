defmodule EyeTest.AssessmentPhoneLiveview do
  use Phoenix.LiveView
  require Logger

  def mount(session, socket) do
    socket = assign(socket, %{assessment_uuid: session.assessment_uuid, display: "blank"})

    if connected?(socket) do
      log socket, "Initialized."
      subscribe(socket)
      broadcast_to_screen(socket, "phone_connected")
    end

    {:ok, socket}
  end

  def render(assigns) do
    EyeTestWeb.AssessmentView.render("phone.html", assigns)
  end

  #
  # Messages from client
  #

  def handle_event("start_test", _params, socket) do
    log socket, "Received start_test event."
    broadcast_to_screen(socket, "start_test")
    {:noreply, socket}
  end

  def handle_event("button_pressed", letter, socket) do
    log socket, "Received button_pressed event, letter: #{letter}."
    broadcast_to_screen(socket, {"button_pressed", letter})
    {:noreply, socket}
  end

  #
  # Messages from server-side
  #

  def handle_info({"display", "blank"} = message, socket) do
    log socket, "Received msg #{inspect(message)}."
    {:noreply, assign(socket, :display, "blank")}
  end

  def handle_info({"display", "get_ready"} = message, socket) do
    log socket, "Received msg #{inspect(message)}."
    {:noreply, assign(socket, :display, "get_ready")}
  end

  def handle_info({"display", "countdown"} = message, socket) do
    log socket, "Received msg #{inspect(message)}."
    {:noreply, assign(socket, :display, "countdown")}
  end

  def handle_info({"display", "letter_buttons"} = message, socket) do
    log socket, "Received msg #{inspect(message)}."
    {:noreply, assign(socket, :display, "letter_buttons")}
  end

  def handle_info({"display", "done"} = message, socket) do
    log socket, "Received msg #{inspect(message)}."
    {:noreply, assign(socket, :display, "done")}
  end

  #
  # Helpers
  #

  defp log(socket, msg) do
    uuid = socket.assigns.assessment_uuid
    Logger.info "AssessmentPhoneLiveview (uuid #{uuid}): #{msg}"
  end

  defp subscribe(socket) do
    channel = "assessment.#{socket.assigns.assessment_uuid}.phone"
    Phoenix.PubSub.subscribe(EyeTest.PubSub, channel)
  end

  defp broadcast_to_screen(socket, event) do
    channel = "assessment.#{socket.assigns.assessment_uuid}.screen"
    Phoenix.PubSub.broadcast(EyeTest.PubSub, channel, event)
  end
end
