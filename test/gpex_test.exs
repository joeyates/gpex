defmodule GpexTest do
  use ExUnit.Case
  alias Gpex

  test "parses" do
    {:ok, gpx_data} = File.read("test/fixtures/minimal.gpx")

    assert Gpex.parse(gpx_data) ==
      %Gpex{
        tracks: [
          %Gpex.Track{
            segments: [
              %Gpex.TrackSegment{
                points: [
                  %Gpex.Point{
                    longitude: 11.47096552,
                    latitude: 43.74124841,
                    elevation: 334.29998779296875,
                    time: ~U[2015-09-19 08:07:38Z]
                  }
                ]
              }
            ]
          }
        ]
      }
  end
end
