defmodule PostTaskTest do
  use ExUnit.Case, async: true
  import Mock

  setup do
    on_exit fn -> TestHelper.cleanup end
  end

  test "Create new post" do
    Mix.Tasks.Obelisk.Init.run([])
    Mix.Tasks.Obelisk.Post.run([ "An awesome post" ])

    assert File.exists? "./posts/#{Obelisk.Date.today}-an-awesome-post.md"
    content = File.read! "./posts/#{Obelisk.Date.today}-an-awesome-post.md"
    assert String.contains? content, "title: An awesome post"
  end

  test "New post has datetime in front matter" do
    with_mock Chronos, [now: fn -> {{2015, 01, 01}, {10, 10, 10}} end, today: fn -> {2015, 01, 01} end] do
      Mix.Tasks.Obelisk.Init.run([])
      Mix.Tasks.Obelisk.Post.run(["Dates should be in frontmatter"])

      assert File.exists? "./posts/2015-01-01-dates-should-be-in-frontmatter.md"
      content = File.read! "./posts/2015-01-01-dates-should-be-in-frontmatter.md"
      assert String.contains? content, "created: 2015-01-01 10:10:10"
    end
  end

  test "Command should fail if no args are passed" do
    Mix.Tasks.Obelisk.Init.run([])
    assert_raise ArgumentError, "Cannot create a new post without the post name", fn ->
      Mix.Tasks.Obelisk.Post.run([])
    end
  end
end
