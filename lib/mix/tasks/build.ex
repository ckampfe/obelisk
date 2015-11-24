defmodule Mix.Tasks.Obelisk.Build do
  use Mix.Task

  @moduledoc """
  This task builds the output of your static site

  ## Switches

  None.
  """

  @shortdoc "Build the static site"

  def run(_) do
    Application.start :yamerl
    Obelisk.start(nil, nil)
    Obelisk.Site.clean
    Obelisk.Assets.copy

    {
      layout_template,
      index_template,
      post_template,
      page_template
    } = Obelisk.Compiler.compile_templates

    _ = Obelisk.Compiler.compile_and_write(
      {:page, layout_template, page_template}
    )

    posts_frontmatter = Obelisk.Compiler.compile_and_write(
      {:post, layout_template, post_template}
    )

    Obelisk.RSS.build_feed(posts_frontmatter)

    Obelisk.Compiler.compile_index(
      posts_frontmatter,
      layout_template,
      index_template
    )
  end
end
