defmodule CompilerTest do
  use ExUnit.Case, async: false
  alias Obelisk.Compiler

  setup do
    TestHelper.cleanup
    on_exit fn -> TestHelper.cleanup end
  end

  defp pagename(day) do
    "page-#{day}"
  end

  defp filename(day) do
    "2014-01-#{day}-post-with-day-#{day}"
  end

  defp create_post(day) do
    File.write("./posts/#{filename(day)}.md", content)
  end

  defp create_page(day) do
    File.write("./pages/#{pagename(day)}.md", content)
  end

  defp content do
    """
    ---
    title: This is the heading
    description: This is the desc
    created: 2014-01-10
    ---

    * And
    * A
    * List
    * Of
    * Things


    "some quoted thing"

    'single quotes' here

    `and some inline code` for good measure
    """
  end

  test "Prepare document" do
    Mix.Tasks.Obelisk.Init.run []
    Mix.Tasks.Obelisk.Build.run []
    create_post(10)
    input_filename = "#{filename(10)}.md"

    layout_template = Compiler.compile_layout
    kind_template = Compiler.compile_post

    post = Compiler.compile(
      :post,
      input_filename,
      layout_template,
      kind_template
    )

    title = post.frontmatter.title
    site_name = Obelisk.Config.config.name

    assert post.frontmatter.title == "This is the heading"
    assert post.frontmatter.description == "This is the desc"
    assert String.contains?(post.document, title <> " - " <> site_name)
  end

  test "file name for post" do
    assert "post.html" == Compiler.md_to_html_extension("path/to/post.md")
  end

  test "html filename with default config" do
    assert "./build/post.html" == Compiler.md_to_html_extension("path/to/post.md") |> Compiler.with_build_path
  end

  test "Build task compiles posts into the build dir" do
    Mix.Tasks.Obelisk.Init.run([])
    Obelisk.Config.reload
    Enum.each(10..15, fn day -> create_post day end)
    Mix.Tasks.Obelisk.Build.run([])

    for day <- 10..15 do
      post = "build/" <> filename(day) <> ".html"
      assert File.exists?(post)
    end
  end

  test "Build task compiled pages into the build dir" do
    Mix.Tasks.Obelisk.Init.run([])
    Obelisk.Config.reload
    Enum.each(10..15, fn day -> create_page day end)
    Mix.Tasks.Obelisk.Build.run([])

    for day <- 10..15 do
      page = "./build/" <> pagename(day) <> ".html"
      assert File.exists?(page)
    end
  end

  test "Index page doesnt include next link on last page" do
    Mix.Tasks.Obelisk.Init.run([])
    Obelisk.Config.reload
    Mix.Tasks.Obelisk.Build.run([])

    assert !String.contains? File.read!("./build/index.html"), "<a href=\"index2.html\">Next Page</a>"
  end

  test "Build task copies assets into the build dir" do
    Mix.Tasks.Obelisk.Init.run([])
    Obelisk.Config.reload
    Mix.Tasks.Obelisk.Build.run([])

    assert File.dir? "./build/assets"
    assert File.dir? "./build/assets/css"
    assert File.dir? "./build/assets/js"
    assert File.dir? "./build/assets/img"
  end

  test "Config limits items per index page" do
    Mix.Tasks.Obelisk.Init.run []
    Obelisk.Config.reload
    for day <- 1..10, do: create_post day
    File.write("site.yml", """
    ---
    name: My Blog
    description: My Blog about things
    url: http://my.blog.com
    posts_per_page: 5
    theme: default
    smartquotes: false
    """)
    Obelisk.Config.reload
    Mix.Tasks.Obelisk.Build.run []

    assert File.exists? "./build/index.html"
    assert File.exists? "./build/index2.html"
    assert File.exists? "./build/index3.html"

    p1 = File.read!("./build/index.html") |> String.split("\.html")
    p2 = File.read!("./build/index2.html") |> String.split("\.html")
    p3 = File.read!("./build/index3.html") |> String.split("\.html")

    assert length(p1) == 7 # one extra for next page
    assert length(p2) == 8 # two extra for both next and prev
    assert length(p3) == 3 # one extra for prev page
  end

  test "build blog with smartquotes" do
    Mix.Tasks.Obelisk.Init.run([])
    1..10 |> Enum.each(&(create_post &1))
    File.write("site.yml", """
    ---
    name: My Blog
    description: My Blog about things
    url: http://my.blog.com
    posts_per_page: 5
    theme: default
    blog_index: "blog.html"
    smartquotes: true
    """)
    Obelisk.Config.reload
    Mix.Tasks.Obelisk.Build.run([])

    f = File.read!("./build/2014-01-1-post-with-day-1.html")
    assert String.contains?(f, "“")
    assert String.contains?(f, "’")
  end

  test "build blog without smartquotes" do
    Mix.Tasks.Obelisk.Init.run([])
    create_post(1)
    File.write("site.yml", """
    ---
    name: My Blog
    description: My Blog about things
    url: http://my.blog.com
    posts_per_page: 5
    theme: default
    blog_index: "blog.html"
    smartquotes: false
    """)
    Obelisk.Config.reload
    Mix.Tasks.Obelisk.Build.run([])

    f = File.read!("./build/2014-01-1-post-with-day-1.html")
    assert String.contains?(f, "“") == false
    assert String.contains?(f, "’") == false
  end

  test "build blog part to different page" do
    Mix.Tasks.Obelisk.Init.run([])
    1..10 |> Enum.each(&(create_post &1))
    File.write("site.yml", """
    ---
    name: My Blog
    description: My Blog about things
    url: http://my.blog.com
    posts_per_page: 5
    theme: default
    blog_index: "blog.html"
    smartquotes: false
    """)
    Obelisk.Config.reload
    Mix.Tasks.Obelisk.Build.run([])

    assert File.exists? "./build/blog.html"
    assert File.exists? "./build/blog2.html"
  end

  test "build blog part to different directory" do
    Mix.Tasks.Obelisk.Init.run([])
    1..10 |> Enum.each(&(create_post &1))
    File.write("site.yml", """
    ---
    name: My Blog
    description: My Blog about things
    url: http://my.blog.com
    posts_per_page: 5
    theme: default
    blog_index: "blog/index.html"
    smartquotes: false
    """)
    Obelisk.Config.reload
    Mix.Tasks.Obelisk.Build.run([])

    assert File.exists? "./build/blog/index.html"
    assert File.exists? "./build/blog/index2.html"
  end

  test "attaches build path to the filename" do
    assert "./build/a-great-post.html" == Compiler.with_build_path("a-great-post.html")
  end

  test "html filename with no config is index.html" do
    assert "./build/index.html" == Compiler.html_filename(1)
  end

  test "html filename page 10 with no config is index10.html" do
    assert "./build/index10.html" == Compiler.html_filename(10)
  end

  test "html filename with single page config is blog.html" do
    Obelisk.Config.force %{blog_index: "blog.html"}
    assert "./build/blog.html" == Compiler.html_filename(1)
  end

  test "html filename with single page 10 config is blog10.html" do
    Obelisk.Config.force %{blog_index: "blog.html"}
    assert "./build/blog10.html" == Compiler.html_filename(10)
  end

  test "html filename with path config is blog/index.html" do
    Obelisk.Config.force %{blog_index: "blog/index.html"}
    assert "./build/blog/index.html" == Compiler.html_filename(1)
  end

  test "html filename with path 10 config is blog/index10.html" do
    Obelisk.Config.force %{blog_index: "blog/index.html"}
    assert "./build/blog/index10.html" == Compiler.html_filename(10)
  end

  test "next page on last page" do
    assert "" == Compiler.next_page(1, true)
  end

  test "next page on not last page" do
    assert "<a href=\"index3.html\">Next Page</a>" == Compiler.next_page(2, false)
  end

  test "prev page on first" do
    assert "" == Compiler.previous_page(1)
  end

  test "prev page on second" do
    assert "<a href=\"index.html\">Previous Page</a>" == Compiler.previous_page(2)
  end

  test "prev page on another" do
    assert "<a href=\"index9.html\">Previous Page</a>" == Compiler.previous_page(10)
  end

  test "next page not on last page with single page config" do
    Obelisk.Config.force %{blog_index: "blog.html"}

    assert "<a href=\"blog3.html\">Next Page</a>" == Compiler.next_page(2, false)
  end

  test "next page not on last page with path config" do
    Obelisk.Config.force %{blog_index: "blog/index.html"}

    assert "<a href=\"blog/index3.html\">Next Page</a>" == Compiler.next_page(2, false)
  end

  test "previous page on second with single page config" do
    Obelisk.Config.force %{blog_index: "blog.html"}

    assert "<a href=\"blog.html\">Previous Page</a>" == Compiler.previous_page(2)
  end

  test "previous page on second with path config" do
    Obelisk.Config.force %{blog_index: "blog/index.html"}

    assert "<a href=\"blog/index.html\">Previous Page</a>" == Compiler.previous_page(2)
  end

  test "previous page on fourth with single page config" do
    Obelisk.Config.force %{blog_index: "blog.html"}

    assert "<a href=\"blog3.html\">Previous Page</a>" == Compiler.previous_page(4)
  end

  test "previous page on fourth with path config" do
    Obelisk.Config.force %{blog_index: "blog/index.html"}

    assert "<a href=\"blog/index3.html\">Previous Page</a>" == Compiler.previous_page(4)
  end
end
