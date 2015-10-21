defmodule Obelisk.Page do
  def prepare(md_file, compiled_layout, compiled_page) do
    Obelisk.Document.prepare(
      "./pages/#{md_file}",
      compiled_layout,
      compiled_page
    )
  end

  def list do
    Obelisk.IO.list("./pages")
  end

  def create(title) do
    Obelisk.IO.create(title, Page)
  end

  def filename_from_title(title) do
    "./pages/#{Obelisk.IO.dashify(title)}.md"
  end
end
