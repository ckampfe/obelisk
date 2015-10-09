defmodule Mix.Tasks.Obelisk.Init do
  use Mix.Task

  @moduledoc """
  This task initializes an Obelisk project.

  ## Switches

  None.
  """

  @shortdoc "Create a new Obelisk project"

  def run(_) do
    Obelisk.Site.initialize
  end
end
