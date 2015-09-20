defmodule GpexTest do
  use ExUnit.Case
  alias Gpex

  test "parse returns a list of points" do
    {:ok, gpx_data} = File.read("test/fixtures/minimal.gpx")
    assert Gpex.parse(gpx_data) == [
      %Gpex.Point{
        elevation: '334.29998779296875',
        latitude: '43.74124841',
        longitude: '11.47096552',
        time: '2015-09-19T08:07:38Z'
      }
    ]
  end
end
