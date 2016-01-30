defmodule YAMLTest do
  use ExUnit.Case, async: false
  alias Obelisk.YAML

  test "can parse front matter" do
    fm = YAML.parse(frontmatter)
    assert fm == %{title: "awesome blog post"}
  end

  test "Can convert yaml to dict" do
    assert %{a: "a", b: "b"} == YAML.convert(%{}, [{'a', 'a'}, {'b', 'b'}])
  end

  defp frontmatter do
    "---\ntitle: awesome blog post"
  end
end
