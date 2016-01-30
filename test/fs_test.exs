defmodule FSTest do
  use ExUnit.Case, asynce: false
  alias Obelisk.FS

  test "file name for post" do
    assert "post.html" == FS.md_to_html_extension("path/to/post.md")
  end

  test "attaches build path to the filename" do
    assert "./build/a-great-post.html" == FS.with_build_path("a-great-post.html")
  end

  test "html filename with no config is index.html" do
    Obelisk.Config.reload
    assert "./build/index.html" == FS.html_filename(1)
  end

  test "html filename page 10 with no config is index10.html" do
    Obelisk.Config.reload
    assert "./build/index10.html" == FS.html_filename(10)
  end

  test "html filename with default config" do
    assert "./build/post.html" == FS.md_to_html_extension("path/to/post.md") |> FS.with_build_path
  end

  test "html filename with single page config is blog.html" do
    Obelisk.Config.force %{blog_index: "blog.html"}
    assert "./build/blog.html" == FS.html_filename(1)
  end

  test "html filename with single page 10 config is blog10.html" do
    Obelisk.Config.force %{blog_index: "blog.html"}
    assert "./build/blog10.html" == FS.html_filename(10)
  end

  test "html filename with path config is blog/index.html" do
    Obelisk.Config.force %{blog_index: "blog/index.html"}
    assert "./build/blog/index.html" == FS.html_filename(1)
  end

  test "html filename with path 10 config is blog/index10.html" do
    Obelisk.Config.force %{blog_index: "blog/index.html"}
    assert "./build/blog/index10.html" == FS.html_filename(10)
  end
end
