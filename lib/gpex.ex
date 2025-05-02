defmodule Gpex do
  defstruct creator: "Gpex",
            version: "1.1",
            xmlns: "http://www.topografix.com/GPX/1/1",
            "xmlns:topografix": "http://www.topografix.com/GPX/Private/TopoGrafix/0/1",
            "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
            "xsi:schemaLocation":
              "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.topografix.com/GPX/Private/TopoGrafix/0/1 http://www.topografix.com/GPX/Private/TopoGrafix/0/1/topografix.xsd",
            tracks: [],
            waypoints: []

  alias Gpex.{Track, Waypoint}

  def parse(text) when is_binary(text) do
    {:ok, {"gpx", attrs, children}} = Saxy.SimpleForm.parse_string(text)
    new(attrs, children)
  end

  def reverse(%__MODULE__{tracks: tracks, waypoints: waypoints}) do
    tracks = tracks |> Enum.map(&Track.reverse/1) |> Enum.reverse()
    %__MODULE__{tracks: tracks, waypoints: waypoints}
  end

  @doc """
  Builds a Gpex struct from a list of attributes and children:

  iex> Gpex.new(%{}, [])
  %Gpex{}

  By default, attributes are set to standard values and tracks and waypoints are set to empty lists:

  iex> Gpex.new(%{}, [])
  %Gpex{
    creator: "Gpex",
    version: "1.1",
    xmlns: "http://www.topografix.com/GPX/1/1",
    "xmlns:topografix": "http://www.topografix.com/GPX/Private/TopoGrafix/0/1",
    "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
    "xsi:schemaLocation":
      "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.topografix.com/GPX/Private/TopoGrafix/0/1 http://www.topografix.com/GPX/Private/TopoGrafix/0/1/topografix.xsd",
    tracks: [],
    waypoints: []
  }

  All top-level attributes can be overridden:

  iex> Gpex.new(%{creator: "Custom Creator"}, [])
  %Gpex{creator: "Custom Creator"}

  Attribute keys can be strings or atoms:

  iex> Gpex.new(%{"version" => "1.0"}, [])
  %Gpex{version: "1.0"}

  The children of the GPX element are parsed into tracks and waypoints:
  iex> Gpex.new(%{}, [
  ...>   {"trk", %{}, [
  ...>     {"desc", %{}, ["Track 1"]},
  ...>     {"trkseg", %{}, [
  ...>       {"trkpt", %{"lat" => "43.553252", "lon" => "11.707813"}, [
  ...>         {"ele", %{}, ["307.6000061035156"]},
  ...>         {"time", %{}, ["2023-10-01T12:00:00Z"]}
  ...>       ]},
  ...>       {"trkpt", %{"lat" => "43.554252", "lon" => "11.708813"}, [
  ...>         {"ele", %{}, ["308.6000061035156"]},
  ...>         {"time", %{}, ["2023-10-01T12:01:00Z"]}
  ...>       ]}
  ...>     ]}
  ...>   ]},
  ...>   {"wpt", %{"lat" => "43.553252", "lon" => "11.707813"}, [
  ...>     {"name", %{}, ["A point of interest"]},
  ...>     {"ele", %{}, ["307.6000061035156"]}
  ...>   ]}
  ...> ])
  %Gpex{
    tracks: [
      %Gpex.Track{
        description: "Track 1",
        segments: [
          %Gpex.TrackSegment{
            points: [
              %Gpex.Point{latitude: 43.553252, longitude: 11.707813, elevation: 307.6000061035156},
              %Gpex.Point{latitude: 43.554252, longitude: 11.708813, elevation: 308.6000061035156}
            ]
          }
        ]
      }
    ],
    waypoints: [
      %Gpex.Waypoint{
        name: "A point of interest",
        latitude: 43.553252,
        longitude: 11.707813,
        elevation: 307.6000061035156
      }
    ]
  }
  """

  def new(attrs, children) when is_list(attrs) do
    attrs = Enum.into(attrs, %{})
    new(attrs, children)
  end

  def new(attrs, children) when is_map(attrs) and is_list(children) do
    attrs = atomify_keys(attrs)

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

    struct!(__MODULE__, Map.merge(attrs, parts))
  end

  defp atomify_keys(attrs) do
    Enum.reduce(attrs, %{}, fn {key, value}, acc ->
      Map.put(acc, atomify(key), value)
    end)
  end

  defp atomify(key) when is_atom(key), do: key
  defp atomify(key) when is_binary(key), do: String.to_existing_atom(key)

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
      attributes =
        gpex
        |> Map.from_struct()
        |> Map.drop([:tracks, :waypoints])

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
