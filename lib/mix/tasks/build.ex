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

    {:ok, store} = Obelisk.Store.start_link

    layout = Obelisk.Document.compile_layout
    index  = Obelisk.Document.compile_index
    post   = Obelisk.Document.compile_post
    page   = Obelisk.Document.compile_page

    Obelisk.Page.list |> Enum.each &(Obelisk.Page.prepare(&1, store, layout, page))
    Obelisk.Post.list |> Enum.each &(Obelisk.Post.prepare(&1, store, layout, post))

    Obelisk.Store.get_pages(store) |> Obelisk.Document.write_all
    Obelisk.Store.get_posts(store) |> Obelisk.Document.write_all

    Obelisk.Store.get_posts(store) |> Obelisk.RSS.build_feed

    Obelisk.Store.get_posts(store) |> Obelisk.Blog.compile_index(layout, index)
  end
end
