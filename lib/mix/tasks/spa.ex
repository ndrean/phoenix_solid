defmodule Mix.Tasks.Spa do
  require Logger
  use Mix.Task

  @spa_path Application.compile_env!(:phx_solid, :spa_dir)

  @shortdoc "Compile and bundle frontend for production"

  @impl Mix.Task
  def run(_) do
    System.cmd("npm", ["run", "build"], cd: "./front")
    System.cmd("rm", ["-rf", @spa_path])
    System.cmd("cp", ["-R", "./front/dist", @spa_path])
    Logger.info(":ok, SPA")
  end
end
