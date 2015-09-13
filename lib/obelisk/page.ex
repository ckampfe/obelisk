defmodule Obelisk.Page do
  def prepare(md_file, compiled_layout, compiled_page) do
    Obelisk.Document.prepare(
      "./pages/#{md_file}",
      compiled_layout,
      compiled_page
    )
  end

  def write(page) do
    File.write(
      page.path,
      page.document
    )

    page
  end

  def list do
    File.ls! "./pages"
  end

  def create(title) do
    File.write(filename_from_title(title), Obelisk.Templates.page(title))
  end

  def filename_from_title(title) do
    titlepart = String.downcase(title) |> String.replace(" ", "-")
    "./pages/#{titlepart}.md"
  end
end
