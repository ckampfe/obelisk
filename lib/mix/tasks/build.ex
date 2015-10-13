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

    _ = prepare_and_write(Obelisk.Page, {layout_template, page_template})
    posts_frontmatter = prepare_and_write(Obelisk.Post, {layout_template, post_template})

    Obelisk.RSS.build_feed(posts_frontmatter)

    Obelisk.Blog.compile_index(
      posts_frontmatter,
      layout_template,
      index_template
    )
  end

  defp prepare_and_write(kind, {layout_template, kind_template}) do
    kind.list
    |> Enum.map(&prepare_async(kind, &1, layout_template, kind_template))
    |> Enum.map(&Task.await(&1, 20000))
    |> Enum.map(&write_async(kind, &1))
    |> Enum.map(&Task.await(&1, 20000))
  end

  defp prepare_async(kind, item, layout_template, kind_template) do
    do_async_supervised(kind, :prepare, [item, layout_template, kind_template])
  end

  defp write_async(kind, item) do
    do_async_supervised(kind, :write, [item])
  end

  defp do_async_supervised(kind, fun, args) do
    Task.Supervisor.async(
      Obelisk.RenderSupervisor,
      kind,
      fun,
      args
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
