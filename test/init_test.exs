defmodule InitTaskTest do
  use ExUnit.Case, async: false

  setup do
    on_exit fn -> TestHelper.cleanup end
  end

  test "Init task creates assets directory structure" do
    Mix.Tasks.Obelisk.Init.run([])

    assert File.dir? "./theme"
    assert File.dir? "./theme"
    assert File.dir? "./theme/assets"
    assert File.dir? "./theme/assets/css"
    assert File.dir? "./theme/assets/js"
    assert File.dir? "./theme/assets/img"
    assert File.exists? "./theme/assets/css/base.css"

    assert File.dir? "./theme/layout"
    assert File.exists? "./theme/layout/layout.eex"
    assert File.exists? "./theme/layout/post.eex"
    assert File.exists? "./theme/layout/page.eex"
  end

  test "Init task creates content directory structure" do
    Mix.Tasks.Obelisk.Init.run([])

    assert File.dir? "./posts"
    assert File.dir? "./drafts"
    assert File.dir? "./pages"
  end

  test "Init task creates initial config file" do
    Mix.Tasks.Obelisk.Init.run([])

    assert File.exists? "./site.yml"
  end

  test "Init task creates first post" do
    Mix.Tasks.Obelisk.Init.run([])

    assert File.exists? "./posts/#{TestHelper.datepart}-welcome-to-obelisk.md"
  end
end
