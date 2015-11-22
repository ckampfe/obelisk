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
    } = Obelisk.Build.compile_templates

    _ = Obelisk.Build.prepare_and_write(
      {Obelisk.Page, layout_template, page_template}
    )

    posts_frontmatter = Obelisk.Build.prepare_and_write(
      {Obelisk.Post, layout_template, post_template}
    )

    Obelisk.RSS.build_feed(posts_frontmatter)

    Obelisk.Build.compile_index(
      posts_frontmatter,
      layout_template,
      index_template
    )
  end
end
