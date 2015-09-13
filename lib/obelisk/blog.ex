defmodule Obelisk.Blog do
  require Integer

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
    {posts_per_page, _} = Integer.parse Obelisk.Config.config.posts_per_page
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

  defp write_index_page(posts, layout_template, index_template, page_num, last_page) do
    index = Obelisk.Document.bind_template(
      index_template,
      assigns: [
        content: posts,
        prev: previous_page(page_num),
        next: next_page(page_num, last_page)
      ]
    )

    layout = Obelisk.Document.bind_template(
      layout_template,
      assigns: [
        css: Obelisk.Assets.css,
        js: Obelisk.Assets.js,
        content: index
      ]
    )

    File.write(
      html_filename(page_num),
      layout
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
    path
    |> String.split("/")
    |> Enum.reverse
    |> _make_path
  end

  defp _make_path([_filename|[]]), do: nil
  defp _make_path([_filename|reverse_path]) do
    [reverse_path] ++ ["build", "."] # Will reverse to ./build/path/unreversed
    |> Enum.reverse
    |> Enum.join("/")
    |> File.mkdir_p
  end

  defp build_index_path(path), do: "./build/" <> path

  defp build_link(path, text), do: "<a href=\"#{path}\">#{text}</a>"

  def previous_page(1),        do: ""
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
end
