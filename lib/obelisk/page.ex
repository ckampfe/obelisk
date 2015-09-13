defmodule Obelisk.Page do
  def prepare(md_file, store, compiled_layout, compiled_page) do
    Obelisk.Store.add_pages(
      store,
      [
        Obelisk.Document.prepare(
          "./pages/#{md_file}",
          compiled_layout,
          compiled_page
        )
      ]
    )
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
