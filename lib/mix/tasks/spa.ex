defmodule Mix.Tasks.Spa do
  require Logger
  use Mix.Task

  @moduledoc """
  Compile and bundle frontend for production. Append absolute path to the key "--path"

  ## Example

      iex> mix spa --path="./priv/static/spa"
  """

  @impl Mix.Task
  def run(arg) do
    {[path: path], _, _} = OptionParser.parse_head(arg, switches: [path: :string])
    # File.rm_rf("_build")
    System.cmd("pnpm", ["run", "build"], cd: "./front")
    System.cmd("rm", ["-rf", path])
    System.cmd("cp", ["-R", "./front/dist", path])
    # System.cmd("mix", ["release"], env: [{"MIX_ENV", "dev"}], cd: "./")
    Logger.info(":ok, SPA")
  end
end
