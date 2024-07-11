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

    %__MODULE__{
      longitude: longitude,
      latitude: latitude,
      elevation: nested[:elevation],
      time: nested[:time]
    }
  end

  defp attribute({"ele", _attrs, [elevation]}) do
    {:elevation, String.to_float(elevation)}
  end

  defp attribute({"time", [], [time]}) when is_binary(time) do
    case DateTime.from_iso8601(time) do
      {:ok, date_time, _rest} ->
        {:time, date_time}

      _ ->
        nil
    end
  end

  defp attribute(_any), do: nil

  defimpl Saxy.Builder do
    import Saxy.XML

    def build(point) do
      attributes = [
        {"lat", point.latitude},
        {"lon", point.longitude}
      ]

      children =
        if point.elevation do
          [{"ele", [], [to_string(point.elevation)]}]
        else
          []
        end

      children =
        if point.time do
          [{"time", [], [DateTime.to_iso8601(point.time)]} | children]
        else
          children
        end

      element("trkpt", attributes, children)
    end
  end
end
