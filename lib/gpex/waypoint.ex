defmodule Gpex.Waypoint do
  @enforce_keys [:longitude, :latitude, :elevation]
  defstruct ~w(longitude latitude elevation name)a

  def new(attrs, children) when is_list(children) do
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
      name: nested[:name]
    }
  end

  defp attribute({"ele", _attrs, [elevation]}) do
    {:elevation, String.to_float(elevation)}
  end

  defp attribute({"name", _attrs, [name]}) do
    {:name, name}
  end

  defp attribute(_any), do: nil

  defimpl Saxy.Builder do
    import Saxy.XML

    def build(waypoint) do
      attributes = [
        {"lat", waypoint.latitude},
        {"lon", waypoint.longitude}
      ]

      children =
        if waypoint.elevation do
          [{"ele", [], [to_string(waypoint.elevation)]}]
        else
          []
        end

      children =
        if waypoint.name do
          [{"name", [], [cdata(waypoint.name)]} | children]
        else
          children
        end

      element("wpt", attributes, children)
    end
  end
end

