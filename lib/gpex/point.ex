defmodule Gpex.Point do
  defstruct ~w(longitude latitude elevation time)a

  def new(attrs, children) do
    attrs = Enum.into(attrs, %{})
    longitude =
      Map.get(attrs, "lon")
      |> String.to_float()
    latitude =
      Map.get(attrs, "lat")
      |> String.to_float()

    nested =
      children
      |> Enum.map(&attribute/1)
      |> Enum.filter(& &1)
      |> Enum.into(%{})

    elevation = nested["elevation"]
    time = nested["time"]

    %__MODULE__{
      longitude: longitude,
      latitude: latitude,
      elevation: elevation,
      time: time
    }
  end

  defp attribute({"ele", _attrs, [elevation]}) do
    {"elevation", String.to_float(elevation)}
  end

  defp attribute({"time", [], [time]}) when is_binary(time) do
    case DateTime.from_iso8601(time) do
      {:ok, date_time, _rest} ->
        {"time", date_time}
      _ ->
        nil
    end
  end

  defp attribute(_any), do: nil

  defimpl Gpex.XML.Encoder do
    def encode(point, _opts \\ []) do
      """
      <trkpt lat="#{point.latitude}" lon="#{point.longitude}">
        #{if point.elevation, do: "<ele>#{point.elevation}</ele>"}
        #{if point.time, do: "<time>#{DateTime.to_iso8601(point.time)}</time>"}
      </trkpt>
      """
    end
  end
end
