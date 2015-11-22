defmodule Obelisk.Document do
  require EEx
  require Obelisk.Template

  # Compile-time macro to define functions that
  # statically compile our template files.
  # See `lib/obelisk/templates.ex`
  @before_compile Obelisk.Template

  def prepare(md_file, layout_template, kind_template) do
    {frontmatter, content} =
      md_file
      |> File.read!
      |> separate_frontmatter_and_content

    frontmatter = Obelisk.FrontMatter.parse(frontmatter)
    document =
      compile_content(frontmatter, md_file, content, kind_template)
      |> compile_document(layout_template)

    %{
      frontmatter: frontmatter,
      document: document,
      path: md_to_html(md_file) |> attach_build_path,
      filename: md_to_html(md_file) |> attach_build_path
    }
  end

  def compile_content(frontmatter, md_file, content, kind_template) do
    compile_template(
      kind_template,
      assigns: [
        content: Earmark.to_html(content),
        frontmatter: frontmatter,
        filename: md_to_html(md_file) |> attach_build_path
      ]
    )
  end

  def compile_document(content, layout_template) do
    compile_template(
      layout_template,
      assigns: [
        css: Obelisk.Assets.css,
        js: Obelisk.Assets.js,
        content: content
      ]
    )
  end

  def compile_template(template, bindings, options \\ []) do
    {result, _} = Code.eval_quoted(template, bindings, options)
    result
  end

  def write(item) do
    File.write!(
      item.path,
      item.document
    )

    item
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

  def dashify(str) do
    String.downcase(str) |> String.replace(" ", "-")
  end

  def attach_build_path(document) do
    Path.join([".", "build", document])
  end

  def md_to_html(path) do
    path
    |> Path.basename(".md")
    |> (&(&1 <> ".html")).()
  end

  def list(kind) do
    File.ls!(kind)
  end
end
