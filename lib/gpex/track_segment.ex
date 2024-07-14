defmodule Gpex.TrackSegment do
  defstruct ~w(points)a

  alias Gpex.Point

  def new(_attrs, children) when is_list(children) do
    points =
      children
      |> Enum.map(fn
        {"trkpt", attrs, children} ->
          Point.new(attrs, children)

        _ ->
          nil
      end)
      |> Enum.filter(& &1)

    %__MODULE__{points: points}
  end

  def reverse(%__MODULE__{points: points}) do
    points = points |> Enum.reverse()
    %__MODULE__{points: points}
  end

  defimpl Saxy.Builder do
    import Saxy.XML

    def build(segment) do
      points =
        segment.points
        |> Enum.map(&Saxy.Builder.build/1)

      element("trkseg", [], points)
    end
  end
end
