defmodule Obelisk.Page do
  def prepare(md_file, compiled_layout, compiled_page) do
    Obelisk.Document.prepare(
      "./pages/#{md_file}",
      compiled_layout,
      compiled_page
    )
  end

  def list do
    Obelisk.Document.list("./pages")
  end

  def create(title) do
    Obelisk.Template.create(title, Page)
  end

  def filename_from_title(title) do
    "./pages/#{Obelisk.Document.dashify(title)}.md"
  end
end
