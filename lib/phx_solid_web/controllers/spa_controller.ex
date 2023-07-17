defmodule PhxSolidWeb.SPAController do
  use PhxSolidWeb, :controller
  require Logger

  # @spa_dir Application.compile_env!(:phx_solid, :spa_dir)
  @title "    <title>Solid App</title>\n"

  defp read_line(:eof, file, _token), do: file

  defp read_line(@title, file, token) do
    file <> @title <> token
  end

  defp read_line(curr, file, _token), do: file <> curr

  defp index_html do
    Application.app_dir(:phx_solid) <> "/" <>
    Application.get_env(:phx_solid, :spa_dir)
    <>  "index.html"
  end

  @doc """
  Reads the index.html generated by the framework and appends the user token for socket.js to collect it
  """
  def index(conn, _params) do

    case Map.has_key?(get_session(conn), "user_token") do
      true ->
        %{"user_token" => user_token} = get_session(conn)
        token =
          "<script nonce='ut'>window.userToken = \"#{user_token}\"</script>\n"

        try do
          index_html()
          |> File.stream!([], :line)
          |> Enum.reduce("", fn l, file ->
            read_line(l, file, token)
          end)
          |> then(fn file ->
            conn
            |> put_resp_content_type("text/html")
            |> send_resp(200, file)
          end)
        rescue
          e ->
            Logger.error("#{__MODULE__}: #{inspect(e.reason)}")
            return(conn, "#{inspect(e.reason)}")
        end

      false ->
        return(conn, "Unauthorized: need to login to access here")
    end
  end

  defp return(conn, msg) do
    conn
    |> clear_flash()
    |> put_flash(:error, msg)
    |> Plug.Conn.put_status(401)
    |> redirect(to: ~p"/")
    |> Plug.Conn.halt()
  end
end
