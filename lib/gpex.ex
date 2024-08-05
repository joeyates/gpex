defmodule Gpex do
  defstruct [
    tracks: [],
    waypoints: []
  ]

  alias Gpex.{Track, Waypoint}

  def parse(text) when is_binary(text) do
    {:ok, {"gpx", attrs, children}} = Saxy.SimpleForm.parse_string(text)
    new(attrs, children)
  end

  def reverse(%__MODULE__{tracks: tracks, waypoints: waypoints}) do
    tracks = tracks |> Enum.map(&Track.reverse/1) |> Enum.reverse()
    %__MODULE__{tracks: tracks, waypoints: waypoints}
  end

  defp new(_attrs, children) when is_list(children) do
    parts =
      children
      |> Enum.reduce(
        %{tracks: [], waypoints: []},
        fn
          {"trk", attrs, children}, acc ->
            update_in(
              acc,
              [:tracks],
              fn t ->
                [Track.new(attrs, children) | t]
              end
            )

          {"wpt", attrs, children}, acc ->
            update_in(
              acc,
              [:waypoints],
              fn w ->
                [Waypoint.new(attrs, children) | w]
              end
            )

          _other, acc ->
            acc
        end
      )
      |> then(fn %{tracks: tracks, waypoints: waypoints} ->
        %{tracks: Enum.reverse(tracks), waypoints: Enum.reverse(waypoints)}
      end)

    struct!(__MODULE__, parts)
  end

  defimpl String.Chars do
    def to_string(gpx) do
      gpx
      |> Saxy.Builder.build()
      |> Saxy.encode!(version: "1.0", encoding: "UTF-8")
    end
  end

  defimpl Saxy.Builder do
    import Saxy.XML

    def build(gpex) do
      attributes = [
        {"xmlns", "http://www.topografix.com/GPX/1/1"},
        {"xmlns:topografix", "http://www.topografix.com/GPX/Private/TopoGrafix/0/1"},
        {"xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance"},
        {"version", "1.1"},
        {"creator", "OpenTracks"},
        {"xsi:schemaLocation",
         "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.topografix.com/GPX/Private/TopoGrafix/0/1 http://www.topografix.com/GPX/Private/TopoGrafix/0/1/topografix.xsd"}
      ]

      waypoints =
        gpex.waypoints
        |> Enum.map(&Saxy.Builder.build/1)

      tracks =
        gpex.tracks
        |> Enum.map(&Saxy.Builder.build/1)

      element("gpx", attributes, waypoints ++ tracks)
    end
  end
end
