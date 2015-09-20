defmodule XML do
  def parse_file(file_name) do
    parse(IO.read(file_name))
  end

  def parse(xml) do
    {elm, _} = :xmerl_scan.string(to_char_list(xml))
    elm
  end
end

defmodule XML.Element do
  alias Expand

  def text(elm) do
    [text_element | _] = :xmerl_xpath.string(to_char_list("./text()"), elm)
    XML.Text.value(text_element)
  end

  def first(doc, xpath) do
    [elm | _] = all(doc, xpath)
    elm
  end

  def all(doc, xpath) do
    :xmerl_xpath.string(to_char_list(xpath), doc)
  end

  defp attributes(elm) do
    {:xmlElement, _name, _, _, _ns, _path, _, attrs, _, _, _, _} = elm
    attrs
  end

  def attribute(elm, name) do
    attributes(elm)
      |> Enum.find(fn(a) -> XML.Attribute.name(a) == name end)
      |> XML.Attribute.value()
  end
end

defmodule XML.Text do
  def value(text_element) do
    {:xmlText, _path, _, _attrs, text, _} = text_element
    text
  end
end

defmodule XML.Attribute do
  def name({:xmlAttribute, name, _, _, _, _, _, _, _value, _}) do
    name
  end

  def value({:xmlAttribute, _name, _, _, _, _, _, _, value, _}) do
    value
  end
end

defmodule Gpex.Point do
  defstruct longitude: nil, latitude: nil, elevation: nil, time: nil

  def from_trkpt(t) do
    elevation = XML.Element.first(t, "/trkpt/ele") |> XML.Element.text()
    time = XML.Element.first(t, "/trkpt/time") |> XML.Element.text()
    longitude = XML.Element.attribute(t, :lon)
    latitude = XML.Element.attribute(t, :lat)
    %Gpex.Point{
      longitude: longitude,
      latitude: latitude,
      elevation: elevation,
      time: time
    }
  end
end

defmodule Gpex do
  def parse(xml) do
    do_parse(xml)
  end

  defp do_parse(xml) do
    XML.parse(xml) |> trkpts() |> points()
  end

  defp trkpts(gpx) do
    XML.Element.all(gpx, "/gpx/trk/trkseg/trkpt")
  end

  defp points([trkpt | rest]) do
    [Gpex.Point.from_trkpt(trkpt) | points(rest)]
  end

  defp points([]) do
    []
  end
end
