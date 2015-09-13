defmodule Obelisk do
  use Application
  import Supervisor.Spec

  def start(_type, __args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Obelisk.Config, [nil]),
      supervisor(Task.Supervisor, [[name: Obelisk.RenderSupervisor]])
    ]

    opts = [strategy: :one_for_one, name: Obelisk.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
