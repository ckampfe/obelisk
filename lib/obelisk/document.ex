defmodule Obelisk.Document do
  require EEx
  require Obelisk.Templates
  import Obelisk.IO, only: [html_path: 1, md_to_html_filename: 1]

  # Compile-time macro to define functions that
  # statically compile our template files.
  # See `lib/obelisk/templates.ex`
  @before_compile Obelisk.Templates

  def prepare(md_file, layout_template, kind_template) do
    {frontmatter, content} =
      md_file
      |> File.read!
      |> separate_frontmatter_and_content

    frontmatter = Obelisk.FrontMatter.parse(frontmatter)
    compiled_content = compile_content(frontmatter, md_file, content, kind_template)
    compiled_document = compile_document(compiled_content, layout_template)

    %{
      frontmatter: frontmatter,
      content: compiled_content,
      document: compiled_document,
      path: html_path(md_file),
      filename: md_to_html_filename(md_file)
    }
  end

  def compile_content(frontmatter, md_file, content, kind_template) do
    bind_template(
      kind_template,
      assigns: [
        content: Earmark.to_html(content),
        frontmatter: frontmatter,
        filename: md_to_html_filename(md_file)
      ]
    )
  end

  def compile_document(compiled_content, layout_template) do
    bind_template(
      layout_template,
      assigns: [
        css: Obelisk.Assets.css,
        js: Obelisk.Assets.js,
        content: compiled_content
      ]
    )
  end

  def bind_template(template, bindings, options \\ []) do
    {result, _} = Code.eval_quoted(template, bindings, options)
    result
  end

  def title(md) do
    md
    |> String.slice(11, 1000)
    |> String.replace("-", " ")
    |> String.replace(".md", "")
    |> String.capitalize
  end

  def separate_frontmatter_and_content(page_content) do
    [frontmatter|content] = String.split page_content, "\n---\n"
    {frontmatter, Enum.join(content, "\n")}
  end
end
