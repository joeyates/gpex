defmodule Gpex do
  defstruct ~w(tracks)a

  alias Gpex.Track

  def parse(text) when is_binary(text) do
    {:ok, {"gpx", attrs, children}} = Saxy.SimpleForm.parse_string(text)
    new(attrs, children)
  end

  defp new(_attrs, children) when is_list(children) do
    tracks =
      children
      |> Enum.map(fn
        {"trk", attrs, children} ->
          Track.new(attrs, children)
        _ ->
          nil
      end)
      |> Enum.filter(& &1)

    %__MODULE__{tracks: tracks}
  end
end
