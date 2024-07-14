defmodule Gpex do
  defstruct ~w(tracks)a

  alias Gpex.Track

  def parse(text) when is_binary(text) do
    {:ok, {"gpx", attrs, children}} = Saxy.SimpleForm.parse_string(text)
    new(attrs, children)
  end

  def reverse(%__MODULE__{tracks: tracks}) do
    tracks = tracks |> Enum.map(&Track.reverse/1) |> Enum.reverse()
    %__MODULE__{tracks: tracks}
  end

  defp new(_attrs, children) when is_list(children) do
    tracks =
      children
      |> Enum.map(fn
        {"trk", attrs, children} ->
          Track.new(attrs, children)

        _ ->
          nil
      end)
      |> Enum.filter(& &1)

    %__MODULE__{tracks: tracks}
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

      tracks =
        gpex.tracks
        |> Enum.map(&Saxy.Builder.build/1)

      element("gpx", attributes, tracks)
    end
  end
end
