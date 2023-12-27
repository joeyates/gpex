defprotocol Gpex.XML.Encoder do
  @doc "Encode as GPX Files"
  def encode(item)
end

defimpl Gpex.XML.Encoder, for: List do
  def encode(list) do
    Enum.map(list, fn item ->
      Gpex.XML.Encoder.encode(item)
    end)
    |> Enum.join("\n")
  end
end
