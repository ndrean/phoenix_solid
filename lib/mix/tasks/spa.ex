defmodule Mix.Tasks.Spa do
  require Logger
  use Mix.Task
  @shortdoc "Compile and bundle frontend for production"

  @spa_path System.fetch_env!("SPA_DIR")

  @impl Mix.Task
  def run(_) do
    System.cmd("pnpm", ["run", "build"], cd: "./front")
    System.cmd("rm", ["-rf", @spa_path])
    System.cmd("cp", ["-R", "./front/dist", @spa_path])
    Logger.info(":ok, SPA")
  end
end
