defmodule PhxSolidWeb.SPAController do
  use PhxSolidWeb, :controller
  require Logger

  @spa_dir Application.compile_env!(:phx_solid, :spa_dir)
  @title "    <title>Solid App</title>\n"

  defp read_line(:eof, file, _token), do: file

  defp read_line(@title, file, token) do
    IO.inspect(token, label: "token")
    file <> @title <> token
  end

  defp read_line(curr, file, _token), do: file <> curr

  @doc """
  Reads the index.html generated by the framework and appends the user token for socket.js to collect it
  """
  def index(conn, _params) do
    case Map.has_key?(get_session(conn), "user_token") do
      true ->
        %{"user_token" => user_token} = get_session(conn)

        token = "<script nonce='ut'>window.userToken = \"#{user_token}\"</script>\n"

        # (@react_dir <> "index.html")
        # (Application.app_dir(:phoenix_react) <> "/" <>
        try do
          (@spa_dir <> "index.html")
          |> File.stream!([], :line)
          |> Enum.reduce("", fn l, file ->
            IO.inspect(l, label: "line")
            read_line(l, file, token)
          end)
          |> then(fn file ->
            IO.inspect(file, label: "file")
            Phoenix.Controller.html(conn, file)
          end)
        rescue
          e in FileError ->
            Logger.error("#{__MODULE__}: #{inspect(e.reason)}")
            return(conn, "#{inspect(e.reason)}")
        end

      false ->
        Logger.error("Need to login to access here")
        return(conn, "Need to login to access the SPA")
    end
  end

  defp return(conn, message) do
    conn
    |> put_flash(:error, "#{message}")
    |> redirect(to: ~p"/")
    |> halt()
  end
end
