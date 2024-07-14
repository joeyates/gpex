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

  describe "reverse/1" do
    @point_1 %Gpex.Point{longitude: 11.0, latitude: 11.0, elevation: 11.0}
    @point_2 %Gpex.Point{longitude: 22.0, latitude: 22.0, elevation: 22.0}
    @point_3 %Gpex.Point{longitude: 33.0, latitude: 33.0, elevation: 33.0}
    @point_4 %Gpex.Point{longitude: 44.0, latitude: 44.0, elevation: 44.0}
    @segment_1 %Gpex.TrackSegment{points: [@point_1, @point_2]}
    @segment_2 %Gpex.TrackSegment{points: [@point_3, @point_4]}
    @track_1 %Gpex.Track{description: "Track 1", segments: [@segment_1, @segment_2]}
    @track_2 %Gpex.Track{description: "Track 2", segments: []}

    test "it reverses the order of the tracks" do
      gpx = %Gpex{tracks: [@track_1, @track_2]}

      reversed = Gpex.reverse(gpx)
      assert Enum.at(reversed.tracks, 0).description == "Track 2"
      assert Enum.at(reversed.tracks, 1).description == "Track 1"
    end

    test "it reverses the order of the segments and points" do
      gpx = %Gpex{tracks: [@track_1]}

      reversed = Gpex.reverse(gpx)
      [first_segment, second_segment] = reversed.tracks |> hd() |> then(& &1.segments)
      assert first_segment.points == [@point_4, @point_3]
      assert second_segment.points == [@point_2, @point_1]
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
