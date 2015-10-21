defmodule IOTest do
  use ExUnit.Case, async: false

  setup do
    TestHelper.cleanup
    on_exit fn -> TestHelper.cleanup end
  end

  test "file name for post" do
    assert "post.html" == Obelisk.IO.md_to_html_filename("path/to/post.md")
  end

  test "html filename with default config" do
    assert "./build/post.html" == Obelisk.IO.html_path("path/to/post.md")
  end
end
