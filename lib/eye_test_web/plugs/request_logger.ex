# One-line full request logging inspired by Plug.Logger.
# See https://github.com/elixir-plug/plug/blob/v1.8.0/lib/plug/logger.ex
# Need to restart the server after updating this file.
defmodule EyeTestWeb.RequestLogger do
  require Logger

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    start_time = System.monotonic_time()

    Plug.Conn.register_before_send(conn, fn(conn) ->
      Logger.log(:info, fn ->
        user = describe_user(conn)
        params = describe_params(conn)
        redirect = describe_redirect(conn)
        duration = describe_duration(start_time)

        "■ [#{conn.method} #{conn.request_path}] user=#{user} params=#{params} "<>
        "status=#{conn.status}#{redirect} duration=#{duration}"
      end)

      conn
    end)
  end

  def describe_params(conn) do
    # Ensure fields like "password" aren't logged
    params = inspect(Phoenix.Logger.filter_values(conn.params))
    # Clean up GraphQL query params for easier readability
    params = Regex.replace(~r/\\n/, params, " ")
    params = Regex.replace(~r/ +/, params, " ")
    params
  end

  def describe_user(conn) do
    # Note the logged-in user assigned from session data
    user = conn.assigns[:current_user]
    if user, do: "#{user.id} (#{user.name})", else: "(none)"
  end

  def describe_redirect(conn) do
    # Note redirect, if any
    redirect = Plug.Conn.get_resp_header(conn, "location")
    if redirect != [], do: " redirected_to=#{redirect}", else: ""
  end

  def describe_duration(start_time) do
    # Calculate time taken (always in ms for consistency)
    stop_time = System.monotonic_time()
    duration_us = System.convert_time_unit(stop_time - start_time, :native, :microsecond)
    duration_ms = div(duration_us, 100) / 10
    "#{duration_ms}ms"
  end
end
