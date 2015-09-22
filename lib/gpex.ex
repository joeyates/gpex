defmodule Gpex.Point do
  import SweetXml

  defstruct longitude: nil, latitude: nil, elevation: nil, time: nil
end

defmodule Gpex do
  import SweetXml

  def parse(xml) do
    xml |> trkpts() |> points()
  end

  defp trkpts(gpx) do
    gpx |> xpath(
      ~x"/gpx/trk/trkseg/trkpt"l,
      elevation: ~x"/trkpt/ele/text()",
      time: ~x"/trkpt/time/text()",
      longitude: ~x"/trkpt/@lon",
      latitude: ~x"/trkpt/@lat",
    )
  end

  defp points([trkpt | rest]) do
    [struct(Gpex.Point, trkpt) | points(rest)]
  end

  defp points([]) do
    []
  end
end
