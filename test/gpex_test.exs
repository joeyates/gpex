defmodule GpexTest do
  use ExUnit.Case
  alias Gpex

  describe "parse/1" do
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

  describe "to_string/1" do
    test "it serializes" do
      {:ok, gpx_data} = File.read("test/fixtures/minimal.gpx")

      assert to_string(Gpex.parse(gpx_data)) ==
               "<?xml version=\"1.0\" encoding=\"UTF-8\"?><gpx xmlns=\"http://www.topografix.com/GPX/1/1\" xmlns:topografix=\"http://www.topografix.com/GPX/Private/TopoGrafix/0/1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" version=\"1.1\" creator=\"OpenTracks\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.topografix.com/GPX/Private/TopoGrafix/0/1 http://www.topografix.com/GPX/Private/TopoGrafix/0/1/topografix.xsd\"><trk><trkseg><trkpt lat=\"43.74124841\" lon=\"11.47096552\"><time>2015-09-19T08:07:38Z</time><ele>334.29998779296875</ele></trkpt></trkseg></trk></gpx>"
    end
  end
end
