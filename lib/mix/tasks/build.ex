defmodule Mix.Tasks.Obelisk.Build do
  use Mix.Task

  @moduledoc """
  This task builds the output of your static site

  ## Switches

  None.
  """

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
    |> Enum.map(fn page ->
      Task.Supervisor.async(
        Obelisk.RenderSupervisor,
        Obelisk.Page,
        :prepare,
        [page, layout_template, page_template]
      )
    end)
    |> Enum.map(&Task.await(&1, 20000))
    |> Enum.map(fn page ->
      Task.Supervisor.async(
        Obelisk.RenderSupervisor,
        Obelisk.Page,
        :write,
        [page]
      )
    end)
    |> Enum.map(&Task.await(&1, 20000))

    posts_frontmatter =
      Obelisk.Post.list
      |> Enum.map(fn post ->
        Task.Supervisor.async(
          Obelisk.RenderSupervisor,
          Obelisk.Post,
          :prepare,
          [post, layout_template, post_template]
        )
      end)
      |> Enum.map(&Task.await(&1, 20000))
      |> Enum.map(fn post ->
        Task.Supervisor.async(
          Obelisk.RenderSupervisor,
          Obelisk.Post,
          :write,
          [post]
        )
      end)
      |> Enum.map(&Task.await(&1, 20000))

    Obelisk.RSS.build_feed(posts_frontmatter)

    Obelisk.Blog.compile_index(
      posts_frontmatter,
      layout_template,
      index_template
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
