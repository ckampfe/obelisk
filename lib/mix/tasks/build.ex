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
    } = compile_templates

    Obelisk.Page.list
    |> Enum.map(&prepare_async(Obelisk.Page, &1, layout_template, page_template))
    |> Enum.map(&Task.await(&1, 20000))
    |> Enum.map(&write_async(Obelisk.Page, &1))
    |> Enum.map(&Task.await(&1, 20000))


    posts_frontmatter =
      Obelisk.Post.list
      |> Enum.map(&prepare_async(Obelisk.Post, &1, layout_template, post_template))
      |> Enum.map(&Task.await(&1, 20000))
      |> Enum.map(&write_async(Obelisk.Post, &1))
      |> Enum.map(&Task.await(&1, 20000))

    Obelisk.RSS.build_feed(posts_frontmatter)

    Obelisk.Blog.compile_index(
      posts_frontmatter,
      layout_template,
      index_template
    )
  end

  defp prepare_async(kind, item, layout_template, kind_template) do
    Task.Supervisor.async(
      Obelisk.RenderSupervisor,
      kind,
      :prepare,
      [item, layout_template, kind_template]
    )
  end

  defp write_async(kind, item) do
    Task.Supervisor.async(
      Obelisk.RenderSupervisor,
      kind,
      :write,
      [item]
    )
  end

  defp compile_templates do
    {
      Obelisk.Document.compile_layout,
      Obelisk.Document.compile_index,
      Obelisk.Document.compile_post,
      Obelisk.Document.compile_page
    }
  end
end
