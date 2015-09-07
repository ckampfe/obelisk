defmodule LayoutTest do
  use ExUnit.Case, async: false

  setup do
    Mix.Tasks.Obelisk.Init.run []
    Obelisk.Config.force %{theme: "default", posts_per_page: 5}
    on_exit fn -> TestHelper.cleanup end
  end

  test "load eex layout" do
    "./themes/default/layout/layout.eex"
    |> File.write("layout")

    assert {"layout", :eex} == Obelisk.Layout.layout
  end

  test "load html.eex layout" do
    "./themes/default/layout/layout.eex"
    |> File.rm

    "./themes/default/layout/layout.html.eex"
    |> File.write("layout")

    assert {"layout", :eex} == Obelisk.Layout.layout
  end

  test "load eex post" do
    "./themes/default/layout/post.eex"
    |> File.write("post")

    assert {"post", :eex} == Obelisk.Layout.post
  end

  test "load html.eex post" do
    "./themes/default/layout/post.eex"
    |> File.rm

    "./themes/default/layout/post.html.eex"
    |> File.write("post")

    assert {"post", :eex} == Obelisk.Layout.post
  end

  test "load eex page" do
    "./themes/default/layout/page.eex"
    |> File.write("page")

    assert {"page", :eex} == Obelisk.Layout.page
  end

  test "load html.eex page" do
    "./themes/default/layout/page.eex"
    |> File.rm

    "./themes/default/layout/page.html.eex"
    |> File.write("page")

    assert {"page", :eex} == Obelisk.Layout.page
  end

  test "load eex index" do
    "./themes/default/layout/index.eex"
    |> File.write("index")

    assert {"index", :eex} == Obelisk.Layout.index
  end

  test "load html.eex index" do
    "./themes/default/layout/index.eex"
    |> File.rm

    "./themes/default/layout/index.html.eex"
    |> File.write("index")

    assert {"index", :eex} == Obelisk.Layout.index
  end
end
