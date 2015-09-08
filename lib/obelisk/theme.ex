defmodule Obelisk.Theme do

  @moduledoc """
  Functions to manage themes.
  """

  @doc """
  Get the currently selected theme as defined in
  `site.yml`

  This will be the repo part only, which will match the
  directory that the theme will be localed in under `/themes`.
  """
  def current do
    Obelisk.Config.config
    |> Dict.get(:theme)
    |> String.split("/")
    |> _current
  end

  defp _current([local]), do: local

  @doc """
  Ensures that the nominated theme is available.
  """
  def ensure do
    Obelisk.Config.config
    |> Dict.get(:theme)
    |> String.split("/")
    |> do_ensure
  end

  defp do_ensure([theme]) do
    case File.dir?("themes/#{theme}") do
      false -> raise(Obelisk.Errors.ThemeNotFound, {:local, theme})
      true -> true
    end
  end
end
