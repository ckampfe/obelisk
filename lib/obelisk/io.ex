defmodule Obelisk.IO do
  def write_html(item) do
    File.write!(
      item.path,
      item.document
    )

    item
  end

  def write_all_html(pages) do
    Enum.each(pages, fn page ->
      write_html(page)
    end)
  end

  def dashify(str) do
    String.downcase(str) |> String.replace(" ", "-")
  end

  def create(title, kind) do
    fn_name =
      Module.split(kind) # break into modules
      |> List.last       # last submodule
      |> String.downcase
      |> String.to_atom

    draft_content =
      apply(
        Obelisk.Templates,
        fn_name,
        [title]
      )

    kind_io_module = Module.concat([Obelisk, kind])

    File.write!(
      kind_io_module.filename_from_title(title),
      draft_content
    )
  end

  def md_to_html_filename(path) do
    path
    |> Path.basename(".md")
    |> (&(&1 <> ".html")).()
  end

  def html_path(md) do
    "./build/#{md_to_html_filename(md)}"
  end

  def list(kind) do
    File.ls!(kind)
  end
end
