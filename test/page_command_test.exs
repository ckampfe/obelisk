defmodule PageTaskTest do
  use ExUnit.Case, async: false

  setup do
    on_exit fn -> TestHelper.cleanup end
  end

  test "Create new post" do
    Mix.Tasks.Obelisk.Init.run([])
    Mix.Tasks.Obelisk.Page.run(["An awesome page"])

    assert File.exists? "./pages/an-awesome-page.md"
    content = File.read! "./pages/an-awesome-page.md"
    assert String.contains? content, "title: An awesome page"
  end

  test "Command should fail if no args are passed" do
    Mix.Tasks.Obelisk.Init.run([])
    assert_raise ArgumentError, "Cannot create a new page without the page name", fn ->
      Mix.Tasks.Obelisk.Page.run([])
    end
  end
end
