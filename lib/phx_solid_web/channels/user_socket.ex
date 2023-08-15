defmodule PhxSolidWeb.UserSocket do
  use Phoenix.Socket
  require Logger

  @moduledoc """
  A Socket handler
  """

  ## Channels
  channel "counter:*", PhxSolidWeb.CounterChannel
  channel "info", PhxSolidWeb.InfoChannel
  channel "bitcoin", PhxSolidWeb.BitcoinChannel

  @impl true
  def connect(%{"token" => token}, socket, _info) do
    Logger.debug("Connect__________#{token}")

    case verify(socket, token) do
      {:ok, user} ->
        # all channels will have access to these assigns
        # socket = assign(socket, name: user.name, user_token: token)
        {:ok, assign(socket, id: user.id, name: user.email)}

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

  # decode the id from the Phoenix.Token
  # and check to the email
  defp verify(_socket, token) do
    with {:ok, id} <- PhxSolid.Token.user_check(token),
         user <- PhxSolid.Accounts.get_user!(id) do
      {:ok, user}
    else
      {:error, reason} -> {:error, reason}
    end

    # case PhxSolid.Token.user_check(token) do
    #   {:ok, email} ->
    #     case PhxSolid.SocialUser.check(:email, email, :id) do
    #       {:ok, social_user} -> {:ok, social_user}
    #       {:error, reason} -> {:error, reason}
    #     end

    #   {:error, reason} ->
    #     {:error, reason}
    # end
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
