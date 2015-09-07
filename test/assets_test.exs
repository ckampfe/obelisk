defmodule AssetsTest do
  use ExUnit.Case, async: false

  setup do
    TestHelper.cleanup
    on_exit fn -> TestHelper.cleanup end
  end

  test "List out css files" do
    Mix.Tasks.Obelisk.Init.run([])
    Obelisk.Config.reload
    File.touch "./themes/default/assets/css/one.css"
    File.touch "./themes/default/assets/css/two.css"
    File.touch "./themes/default/assets/css/three.css"
    Mix.Tasks.Obelisk.Build.run([])

    files = Obelisk.Assets.css_files
    assert 4 == Enum.count(files)
    assert Enum.find(files, &(&1 == "assets/css/base.css")) != nil
    assert Enum.find(files, &(&1 == "assets/css/one.css")) != nil
    assert Enum.find(files, &(&1 == "assets/css/two.css")) != nil
    assert Enum.find(files, &(&1 == "assets/css/three.css")) != nil
  end

  test "List of css files should not include directories" do
    Mix.Tasks.Obelisk.Init.run([])
    Obelisk.Config.reload
    File.mkdir "./themes/default/assets/css/folder"
    Mix.Tasks.Obelisk.Build.run([])

    files = Obelisk.Assets.css_files
    assert 1 == Enum.count(files)
    assert Enum.find(files, &(&1 == "assets/css/base.css")) != nil
  end

  test "List out js files" do
    Mix.Tasks.Obelisk.Init.run([])
    Obelisk.Config.reload
    File.touch "./themes/default/assets/js/one.js"
    Mix.Tasks.Obelisk.Build.run([])

    files = Obelisk.Assets.js_files
    assert 1 == Enum.count(files)
    assert Enum.find(files, &(&1 == "assets/js/one.js")) != nil
  end

  test "List of js files should not include directories" do
    Mix.Tasks.Obelisk.Init.run([])
    Obelisk.Config.reload
    File.touch "./themes/default/assets/js/one.js"
    File.mkdir "./themes/default/assets/js/folder"
    Mix.Tasks.Obelisk.Build.run([])

    files = Obelisk.Assets.js_files
    assert 1 == Enum.count(files)
    assert Enum.find(files, &(&1 == "assets/js/one.js")) != nil
  end

  test "Get html to reference css" do
    Mix.Tasks.Obelisk.Init.run([])
    Obelisk.Config.reload
    Mix.Tasks.Obelisk.Build.run([])

    css_links = Obelisk.Assets.css
    assert css_links == "<link rel=\"stylesheet\" href=\"assets/css/base.css\" />"
  end

  test "Get html to load js" do
    Mix.Tasks.Obelisk.Init.run([])
    Obelisk.Config.reload
    File.touch "./themes/default/assets/js/one.js"
    Mix.Tasks.Obelisk.Build.run([])

    js_links = Obelisk.Assets.js
    assert js_links == "<script type=\"text/javascript\" src=\"assets/js/one.js\"></script>"
  end
end
