defmodule DocumentTest do
  use ExUnit.Case, async: false

  setup do
    TestHelper.cleanup
    on_exit fn -> TestHelper.cleanup end
  end

  test "Prepare document" do
    Mix.Tasks.Obelisk.Init.run []
    Mix.Tasks.Obelisk.Build.run []
    create_post(10)
    file = "./posts/#{filename(10)}.md"

    layout = Obelisk.Document.compile_layout
    page   = Obelisk.Document.compile_page

    document = Obelisk.Document.prepare file, layout, page
    assert document.frontmatter.title == "This is the heading"
    assert document.frontmatter.description == "This is the desc"
  end

  test "file name for post" do
    assert "post.html" == Obelisk.Document.file_name("path/to/post.md")
  end

  test "html filename with default config" do
    assert "./build/post.html" == Obelisk.Document.html_filename("path/to/post.md")
  end

  defp filename(day) do
    "2014-01-#{day}-post-with-day-#{day}"
  end

  defp create_post(day) do
    File.write("./posts/#{filename(day)}.md", content)
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

    `and some inline code` for good measure
    """
  end
end
