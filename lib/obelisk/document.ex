defmodule Obelisk.Document do
  require EEx

  def compile_layout do
    EEx.compile_file "./theme/layout/layout.eex"
  end

  def compile_index do
    EEx.compile_file "./theme/layout/index.eex"
  end

  def compile_post do
    EEx.compile_file "./theme/layout/post.eex"
  end

  def compile_page do
    EEx.compile_file "./theme/layout/page.eex"
  end

  def bind_template(compiled, bindings, options \\ []) do
    {result, _} = Code.eval_quoted(compiled, bindings, options)
    result
  end

  def prepare(md_file, layout, inner) do
    {yaml_frontmatter, content} =
      md_file
      |> File.read!
      |> parts

    frontmatter = Obelisk.FrontMatter.parse(yaml_frontmatter)

    compiled_content = bind_template(
      inner,
      assigns: [
        content: Earmark.to_html(content),
        frontmatter: frontmatter,
        filename: file_name(md_file)
      ]
    )

    compiled_document = bind_template(
      layout,
      assigns: [
        css: Obelisk.Assets.css,
        js: Obelisk.Assets.js,
        content: compiled_content
      ]
    )

    %{
      frontmatter: frontmatter,
      content: compiled_content,
      document: compiled_document,
      path: html_filename(md_file),
      filename: file_name(md_file)
    }
  end

  def write_all(pages) do
    Enum.each pages, fn page ->
      File.write page.path, page.document
    end
  end

  def file_name(path) do
    path
    |> Path.basename(".markdown")
    |> Path.basename(".md")
    |> (&(&1 <> ".html")).()
  end

  def html_filename(md) do
    "./build/#{file_name(md)}"
  end

  def title(md) do
    md
    |> String.slice(11, 1000)
    |> String.replace("-", " ")
    |> String.replace(".markdown", "")
    |> String.replace(".md", "")
    |> String.capitalize
  end

  def parts(page_content) do
    [frontmatter|content] = String.split page_content, "\n---\n"
    {frontmatter, Enum.join(content, "\n")}
  end

  def create(title) do
    File.write(filename_from_title(title), Obelisk.Templates.post(title))
  end

  def filename_from_title(title) do
    datepart = Chronos.today |> Chronos.Formatter.strftime("%Y-%0m-%0d")
    titlepart = String.downcase(title) |> String.replace(" ", "-")
    "./posts/#{datepart}-#{titlepart}.md"
  end
end
