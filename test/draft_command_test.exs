defmodule DraftTaskTest do
  use ExUnit.Case, async: false

  setup do
    on_exit fn -> TestHelper.cleanup end
  end

  test "Create new draft" do
    Mix.Tasks.Obelisk.Init.run([])
    Mix.Tasks.Obelisk.Draft.run(["Not quite ready yet"])

    assert File.exists? "./drafts/#{Obelisk.Date.today}-not-quite-ready-yet.md"
    content = File.read! "./drafts/#{Obelisk.Date.today}-not-quite-ready-yet.md"
    assert String.contains? content, "title: Not quite ready yet"
  end

  test "Command should fail if no args are passed" do
    Mix.Tasks.Obelisk.Init.run([])
    assert_raise ArgumentError, "Cannot create a new draft without the post name", fn ->
      Mix.Tasks.Obelisk.Draft.run([])
    end
  end
end
