defmodule Gpex.Track do
  defstruct ~w(description type segments)a

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

    nested =
      children
      |> Enum.map(&attribute/1)
      |> Enum.filter(& &1)
      |> Enum.into(%{})

    %__MODULE__{description: nested[:description], type: nested[:type], segments: segments}
  end

  def reverse(%__MODULE__{segments: segments} = track) do
    segments = segments |> Enum.map(&TrackSegment.reverse/1) |> Enum.reverse()
    %__MODULE__{track | segments: segments}
  end

  defp attribute({"desc", _attrs, [description]}) do
    {:description, description}
  end

  defp attribute({"type", _attrs, [type]}) do
    {:type, type}
  end

  defp attribute(_any), do: nil

  defimpl Saxy.Builder do
    import Saxy.XML

    def build(track) do
      children =
        track.segments
        |> Enum.map(&Saxy.Builder.build/1)

      children =
        if track.description do
          [{"desc", [], [cdata(track.description)]} | children]
        else
          children
        end

      children =
        if track.type do
          [{"type", [], [cdata(track.type)]} | children]
        else
          children
        end

      element("trk", [], children)
    end
  end
end
