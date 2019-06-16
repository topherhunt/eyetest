defmodule EyeTest.Telemetry do
  require Logger

  # Thanks to https://hexdocs.pm/ecto/Ecto.Repo.html#module-telemetry-events
  def handle_event([:eye_test, :repo, :query], measurements, metadata, _config) do
    Logger.log(:debug, fn ->
      {ok, _} = metadata.result
      source = inspect(metadata.source)
      time = div(measurements.query_time, 100_000) / 10
      # Strip out unnecessary quotes from the query for readability
      query = Regex.replace(~r/(\d\.)"([^"]+)"/, metadata.query, "\\1\\2")
      params = inspect(metadata.params, charlists: false)

      "SQL query: #{ok} source=#{source} db=#{time}ms   #{query}   params=#{params}"
    end)
  end
end
