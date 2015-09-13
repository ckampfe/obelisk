defmodule LayoutTest do
  use ExUnit.Case, async: false

  setup do
    Mix.Tasks.Obelisk.Init.run []
    Obelisk.Config.force %{theme: "default", posts_per_page: 5}
    on_exit fn -> TestHelper.cleanup end
  end

  test "load eex layout" do
    "./theme/layout/layout.eex"
    |> File.write("layout")

    assert "layout" == Obelisk.Layout.layout
  end

  test "load html.eex layout" do
    "./theme/layout/layout.eex"
    |> File.rm

    "./theme/layout/layout.html.eex"
    |> File.write("layout")

    assert "layout" == Obelisk.Layout.layout
  end

  test "load eex post" do
    "./theme/layout/post.eex"
    |> File.write("post")

    assert "post" == Obelisk.Layout.post
  end

  test "load html.eex post" do
    "./theme/layout/post.eex"
    |> File.rm

    "./theme/layout/post.html.eex"
    |> File.write("post")

    assert "post" == Obelisk.Layout.post
  end

  test "load eex page" do
    "./theme/layout/page.eex"
    |> File.write("page")

    assert "page" == Obelisk.Layout.page
  end

  test "load html.eex page" do
    "./theme/layout/page.eex"
    |> File.rm

    "./theme/layout/page.html.eex"
    |> File.write("page")

    assert "page" == Obelisk.Layout.page
  end

  test "load eex index" do
    "./theme/layout/index.eex"
    |> File.write("index")

    assert "index" == Obelisk.Layout.index
  end

  test "load html.eex index" do
    "./theme/layout/index.eex"
    |> File.rm

    "./theme/layout/index.html.eex"
    |> File.write("index")

    assert "index" == Obelisk.Layout.index
  end
end
