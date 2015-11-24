defmodule Mix.Tasks.Obelisk.Page do
  use Mix.Task

  @moduledoc """
  This task creates a new page with the given page title argument as part of the filename,
  and included in the front matter title

  ## Arguments

  * Page title

  ## Usage

      $ mix obelisk page "This one weird trick"
  """

  @shortdoc "Create a new page"

  @doc """
  Run the build task
  """
  def run([]), do: raise(ArgumentError, message: "Cannot create a new page without the page name")
  def run([title]), do: Obelisk.Template.create(title, :page)
end
