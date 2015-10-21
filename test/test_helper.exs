ExUnit.start()

defmodule TestHelper do
  def cleanup do
    Obelisk.Config.reload
    File.rm_rf "./theme"
    File.rm "./site.yml"
    File.rm_rf "./pages"
    File.rm_rf "./posts"
    File.rm_rf "./drafts"
    File.rm_rf "./build"
    Mix.Tasks.Obelisk.Init.run([])
  end
end
