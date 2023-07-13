defmodule PhxSolidWeb.UserSocket do
  use Phoenix.Socket
  require Logger

  @moduledoc """
  A Socket handler
  """

  ## Channels
  channel "counter", PhxSolidWeb.CounterChannel
  channel "info", PhxSolidWeb.InfoChannel

  @impl true
  def connect(%{"token" => token} = _params, socket, _info) do
    case verify(socket, token) do
      {:ok, user} ->
        # all channels will have access to these assigns
        socket = assign(socket, name: user.name, user_token: token)
        {:ok, socket}

      {:error, err} ->
        Logger.error("#{__MODULE__}: error: #{inspect(err)}")
        # define an error handler in the websocket configuration
        # (https://hexdocs.pm/phoenix/Phoenix.Endpoint.html#socket/3-websocket-configuration).
        :error
    end
  end

  def connect(_, _socket, _) do
    Logger.error("#{__MODULE__}: missing params")
    :error
  end

  defp verify(_socket, token) do
    case PhxSolid.Token.user_check(token) do
      {:ok, email} ->
        case PhxSolid.User.check(:email, email, :id) do
          {:ok, user} -> {:ok, user}
          {:error, reason} -> {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Elixir.PhxSolidWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil
end
