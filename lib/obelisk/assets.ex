defmodule Obelisk.Assets do
  alias Obelisk.FS

  def copy, do: FS.copy_dir("./theme/assets", "./build/assets")

  def css_files, do: FS.built_asset_files("css")
  def js_files, do: FS.built_asset_files("js")

  def css do
    css_files
    |> Enum.map(&("<link rel=\"stylesheet\" href=\"#{&1}\" />"))
    |> Enum.join("\n")
  end

  def js do
    js_files
    |> Enum.map(&("<script type=\"text/javascript\" src=\"#{&1}\"></script>"))
    |> Enum.join("\n")
  end
end
