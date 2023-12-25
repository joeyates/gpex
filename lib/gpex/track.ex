defmodule Gpex.Track do
  defstruct ~w(segments)a

  alias Gpex.TrackSegment

  def new(_attrs, children) when is_list(children) do
    segments =
      children
      |> Enum.map(fn
        {"trkseg", attrs, children} ->
          TrackSegment.new(attrs, children)
        _ ->
          nil
      end)
      |> Enum.filter(& &1)

    %__MODULE__{segments: segments}
  end
end
