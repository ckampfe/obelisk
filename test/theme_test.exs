defmodule ThemeTest do
  use ExUnit.Case, async: false

  setup do
    on_exit fn -> TestHelper.cleanup end
  end

  test "Local theme raises error when theme doesnt exist" do
    Obelisk.Config.force %{theme: "missing"}
    assert_raise Obelisk.Errors.ThemeNotFound, fn ->
      Obelisk.Theme.ensure
    end
  end

  test "Default theme works" do
    Mix.Tasks.Obelisk.Init.run []
    "default" = Obelisk.Config.config |> Dict.get(:theme)
    assert Obelisk.Theme.ensure
  end

  test "get current local theme" do
    Obelisk.Config.force %{theme: "testtheme"}
    assert "testtheme" == Obelisk.Theme.current
  end
end
