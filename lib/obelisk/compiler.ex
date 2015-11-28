defmodule Obelisk.Compiler do
  require Obelisk.Template

  @before_compile Obelisk.Template

  def compile(kind, input_filename, layout_template, kind_template) do
    site = Obelisk.Config.config

    {yaml_frontmatter, md_content} =
      Path.join([path_for(kind), input_filename])
      |> File.read!
      |> separate_frontmatter_and_content

    html = Earmark.to_html(md_content)

    frontmatter = Obelisk.FrontMatter.parse(yaml_frontmatter)

    compiled_content = compile_content(
      frontmatter,
      input_filename,
      html,
      kind_template
    )

    compiled_document = compile_document(
      compiled_content,
      layout_template,
      frontmatter.title,
      site.name
    )

    output_filename = md_to_html_extension(input_filename)

    %{
      frontmatter: frontmatter,
      document:    compiled_document,
      path:        output_filename |> with_build_path
    }
  end

  def compile_content(frontmatter, input_filename, content, kind_template) do
    compile_template(
      kind_template,
      assigns: [
        content: content,
        frontmatter: frontmatter,
        filename: md_to_html_extension(input_filename) |> with_build_path
      ]
    )
  end

  def compile_document(content, layout_template, title, site_name) do
    compile_template(
      layout_template,
      assigns: [
        css: Obelisk.Assets.css,
        js: Obelisk.Assets.js,
        content: content,
        title: title,
        site_name: site_name
      ]
    )
  end

  def compile_template(template, assigns, options \\ []) do
    {result, _} = Code.eval_quoted(template, assigns, options)
    result
  end

  def compile_and_write({kind, _, _}=opts) do
    items = list(kind)
    schedulers = number_of_vm_schedulers
    workers = bucket_work_by_schedulers(items, schedulers)
    Enum.flat_map(workers, &do_compile_and_write_batch(&1, opts))
  end

  defp do_compile_and_write_batch(batch, {kind, layout_template, kind_template}) do
    batch
    |> Enum.map(&compile_async(kind, &1, layout_template, kind_template))
    |> Enum.map(&Task.await(&1, 20000))
    |> Enum.map(&write_async(&1))
    |> Enum.map(&Task.await(&1, 20000))
  end

  defp bucket_work_by_schedulers(items, number_of_schedulers) do
    Enum.with_index(items)
    |> Enum.group_by(fn({_el, index}) ->
      rem(index, number_of_schedulers)
    end)
    |> Enum.map(fn({_scheduler_number, coll}) ->
      Enum.map(coll, fn({el, _index}) -> el end)
    end)
  end

  defp compile_async(kind, item, layout_template, kind_template) do
    do_async_supervised(
      Obelisk.Compiler,
      :compile,
      [kind, item, layout_template, kind_template]
    )
  end

  defp write_async(item) do
    do_async_supervised(Obelisk.Compiler, :write, [item])
  end

  def write(item) do
    File.write!(item.path, item.document)
    item
  end

  defp do_async_supervised(kind, fun, args) do
    Task.Supervisor.async(
      Obelisk.RenderSupervisor,
      kind,
      fun,
      args
    )
  end

  def compile_templates do
    {
      Obelisk.Compiler.compile_layout,
      Obelisk.Compiler.compile_index,
      Obelisk.Compiler.compile_post,
      Obelisk.Compiler.compile_page
    }
  end

  defp number_of_vm_schedulers do
    :erlang.system_info(:schedulers_online)
  end

  def compile_index(posts, layout_template, index_template) do
    Obelisk.Config.config
    |> Map.get(:blog_index)
    |> make_path

    posts
    |> Enum.sort(&(&1.frontmatter.created >= &2.frontmatter.created))
    |> do_compile_index(layout_template, index_template, 1)
  end

  defp do_compile_index([], _, _, _), do: nil
  defp do_compile_index(posts, layout_template, index_template, page_num) do
    {posts_per_page, _} = Integer.parse(Obelisk.Config.config.posts_per_page)
    {current, remaining} = Enum.split(posts, posts_per_page)
    write_index_page(
      current,
      layout_template,
      index_template,
      page_num,
      last_page?(remaining)
    )

    do_compile_index(remaining, layout_template, index_template, page_num + 1)
  end

  defp write_index_page(
    posts,
    layout_template,
    index_template,
    page_num,
    last_page
  ) do

    index_content = compile_template(
      index_template,
      assigns: [
        content: posts,
        prev: previous_page(page_num),
        next: next_page(page_num, last_page)
      ]
    )

    index_page = compile_template(
      layout_template,
      assigns: [
        css: Obelisk.Assets.css,
        js: Obelisk.Assets.js,
        content: index_content,
        site_name: Obelisk.Config.config.name
      ]
    )

    File.write(
      html_filename(page_num),
      index_page
    )
  end

  defp last_page?([]), do: true
  defp last_page?(_),  do: false

  def html_filename(page_num) do
    Obelisk.Config.config
    |> Map.get(:blog_index)
    |> with_index_num(page_num)
    |> build_index_path
  end

  defp with_index_num(nil, 1), do: "index.html"
  defp with_index_num(nil, page_num), do: "index#{page_num}.html"
  defp with_index_num(index_filename, 1), do: index_filename
  defp with_index_num(index_filename, page_num) do
    extension = Path.extname(index_filename)
    path = Path.rootname(index_filename, extension)
    path <> to_string(page_num) <> extension
  end

  defp make_path(nil), do: nil
  defp make_path(path) do
    case Path.dirname(path) do
      "."     -> nil
      subpath -> Path.join("./build", subpath) |> File.mkdir_p
    end
  end

  defp build_index_path(path), do: Path.join([".", "build", path])

  defp build_link(path, text), do: "<a href=\"#{path}\">#{text}</a>"

  def previous_page(1), do: ""
  def previous_page(page_num) do
    Obelisk.Config.config
    |> Map.get(:blog_index)
    |> with_index_num(page_num - 1)
    |> build_link("Previous Page")
  end

  def next_page(_page_num, true),  do: ""
  def next_page(page_num,  false) do
    Obelisk.Config.config
    |> Map.get(:blog_index)
    |> with_index_num(page_num + 1)
    |> build_link("Next Page")
  end

  def separate_frontmatter_and_content(page_content) do
    [frontmatter|content] = String.split page_content, "\n---\n"
    {frontmatter, Enum.join(content, "\n")}
  end

  def dashify(str) do
    String.downcase(str) |> String.replace(" ", "-")
  end

  def with_build_path(filename) do
    Path.join([".", "build", filename])
  end

  def md_to_html_extension(path) do
    path
    |> Path.basename(".md")
    |> (&(&1 <> ".html")).()
  end

  def list(kind) do
    path_for(kind) |> File.ls!
  end

  def filename_to_title(md) do
    String.slice(md, 11, 1000)
    |> String.replace("-", " ")
    |> String.replace(".md", "")
    |> String.capitalize
  end

  def title_to_filename(title, kind) do
    date = Obelisk.Date.today

    combined =
      case kind do
        :post -> date <> "-" <> title
        :page -> title
        :draft -> date <> "-" <> title
      end

    Path.join(to_string(kind) <> "s", "#{dashify(combined)}.md")
  end

  defp path_for(kind) do
    Path.join(".", to_string(kind) <> "s")
  end
end
