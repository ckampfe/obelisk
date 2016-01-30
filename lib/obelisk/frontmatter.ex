defmodule Obelisk.YAML do
  def parse(yaml) do
    convert(%{}, hd(:yamerl_constr.string(yaml)))
  end

  def convert(map, []), do: map
  def convert(map, [head|tail]) do
    {k, v} = head

    key =  to_string(k) |> String.to_atom
    value = to_string(v)

    map
    |> Map.put(key, value)
    |> convert(tail)
  end
end
