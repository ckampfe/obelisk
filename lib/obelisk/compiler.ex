defmodule Obelisk.Compiler do
  require Obelisk.Template

  @before_compile Obelisk.Template

  def compile(kind, md_file, layout_template, kind_template) do
    {frontmatter, content} =
      Path.join([path_for(kind), md_file])
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
    |> Dict.get(:blog_index)
    |> make_path

    posts
    |> Enum.sort(&(&1.frontmatter.created >= &2.frontmatter.created))
    |> do_compile_index(layout_template, index_template)
  end

  defp do_compile_index([], _, _, _), do: nil
  defp do_compile_index(posts, layout_template, index_template, page_num \\ 1) do
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
        content: index_content
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
    |> Dict.get(:blog_index)
    |> with_index_num(page_num)
    |> build_index_path
  end

  defp with_index_num(nil, 1), do: "index.html"
  defp with_index_num(nil, page_num), do: "index#{page_num}.html"
  defp with_index_num(c, 1), do: c
  defp with_index_num(c, page_num) do
    [ext|reverse_path] = c
    |> String.split(".")
    |> Enum.reverse

    p = reverse_path
    |> Enum.reverse
    |> Enum.join

    p <> to_string(page_num) <> "." <> ext
  end

  defp make_path(nil), do: nil
  defp make_path(path) do
    case Path.dirname(path) do
      "."     -> nil
      subpath -> Path.join("./build", subpath) |> File.mkdir_p
    end
  end

  defp build_index_path(path), do: "./build/" <> path

  defp build_link(path, text), do: "<a href=\"#{path}\">#{text}</a>"

  def previous_page(1), do: ""
  def previous_page(page_num) do
    Obelisk.Config.config
    |> Dict.get(:blog_index)
    |> with_index_num(page_num - 1)
    |> build_link("Previous Page")
  end

  def next_page(_page_num, true),  do: ""
  def next_page(page_num,  false) do
    Obelisk.Config.config
    |> Dict.get(:blog_index)
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

  def attach_build_path(document) do
    Path.join([".", "build", document])
  end

  def md_to_html(path) do
    path
    |> Path.basename(".md")
    |> (&(&1 <> ".html")).()
  end

  def list(kind) do
    Path.join(".", to_string(kind) <> "s") |> File.ls!
  end

  def filename_to_title(md) do
    String.slice(md, 11, 1000)
    |> String.replace("-", " ")
    |> String.replace(".md", "")
    |> String.capitalize
  end

  def title_to_filename(title, kind) do
    datepart = Obelisk.Date.today
    titlepart = dashify(title)

    combined =
      case kind do
        :post -> datepart <> "-" <> titlepart
        :page -> titlepart
        :draft -> datepart <> "-" <> titlepart
      end

    # "./posts/#{datepart}-#{titlepart}.md"
    Path.join([to_string(kind) <> "s", "#{combined}.md"])
  end

  def path_for(kind) do
    %{draft: "./drafts",
      post: "./posts",
      page: "./pages"}
    |> Map.fetch!(kind)
  end
end
