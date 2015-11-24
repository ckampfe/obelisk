defmodule Mix.Tasks.Obelisk.Post do
  use Mix.Task

  @moduledoc """
  This task creates a new post with the given post title argument as part of the filename,
  and included in the front matter title

  ## Arguments

  * Post title

  ## Usage

      $ mix obelisk post "This one wierd trick"
  """

  @shortdoc "Create a new post"

  @doc """
  Run the build task
  """
  def run([]) do
    raise ArgumentError, message: "Cannot create a new post without the post name"
  end

  @doc """
  Run the build task
  """
  def run([title]), do: Obelisk.Template.create(title, :post)
end
