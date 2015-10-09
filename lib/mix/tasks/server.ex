defmodule Mix.Tasks.Obelisk.Server do
  use Mix.Task

  @moduledoc """
  This task starts the Obelisk server

  ## Switches

  None.
  """

  @shortdoc "Start a server to preview your static site locally"

  def run(_) do
    Application.start :cowboy
    Application.start :plug
    IO.puts "Starting Cowboy server. Browse to http://localhost:4000/"
    IO.puts "Press <CTRL+C> <CTRL+C> to quit."
    {:ok, pid} = Plug.Adapters.Cowboy.http Obelisk.Plug.Server, []

    unless Code.ensure_loaded?(IEx) && IEx.started? do
      :timer.sleep(:infinity)
    end
  end
end
