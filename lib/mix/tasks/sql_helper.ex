defmodule Mix.Tasks.Sql.Clean do
  @shortdoc "clean the migration file to raw SQL"

  require Logger
  use Mix.Task

  @impl Mix.Task
  def run(arg) do
    # filename = System.argv()
    case arg do
      [] ->
        Logger.debug("Please enter a filename")

      [filename] ->
        with {:ok, txt} <- File.read(filename) do
          txt
          |> String.split("\n")
          |> Enum.filter(
            &((String.contains?(&1, "CREATE") or String.contains?(&1, "ALTER")) and
                not String.contains?(&1, "execute"))
          )
          |> Enum.map(&String.replace(&1, "[]", ";"))
          |> to_string()
          |> then(fn t -> File.write(filename, t) end)
        end

        System.cmd(
          "echo",
          ["\e[32m \u2714 \e[0m", " File ready for conversion to dbml"],
          into: IO.stream()
        )
    end
  end
end

defmodule Mix.Tasks.Sql.Prepare do
  @shortdoc "wrap the raw SQL for a commit"

  require Logger
  use Mix.Task

  @impl Mix.Task
  def run(arg) do
    # filename = System.argv()
    case arg do
      [] ->
        Logger.debug("Please enter a filename")

      [filename] ->
        filename
        |> File.write("COMMIT;", [:append])
        |> then(fn _ ->
          {:ok, txt} = File.read(filename)
          File.write(filename, "BEGIN;" <> txt)
        end)

        System.cmd("echo", ["\e[32m \u2714 \e[0m", " Ready for transaction"], into: IO.stream())
    end
  end
end
