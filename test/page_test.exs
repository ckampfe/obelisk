defmodule PageTest do
  use ExUnit.Case, async: false
  setup do
    TestHelper.cleanup
    on_exit fn -> TestHelper.cleanup end
  end

  test "can list pages" do
    Mix.Tasks.Obelisk.Init.run([])
    File.touch "./pages/about-me.md"
    pages = Obelisk.FS.list(:page)
    assert 1 == Enum.count(pages)
    [h|_] = pages
    assert h == "about-me.md"
  end
end
