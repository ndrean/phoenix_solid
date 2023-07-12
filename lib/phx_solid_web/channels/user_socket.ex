defmodule PhxSolidWeb.UserSocket do
  use Phoenix.Socket
  require Logger

  # A Socket handler
  #
  # It's possible to control the websocket connection and
  # assign values that can be accessed by your channel topics.

  ## Channels
  channel "counter", PhxSolidWeb.CounterChannel
  channel "info", PhxSolidWeb.InfoChannel
  # channel("ctx:*", PhxSolidWeb.CtxChannel)
  #
  # To create a channel file, use the mix task:
  #
  #     mix phx.gen.channel Room
  #
  # See the [`Channels guide`](https://hexdocs.pm/phoenix/channels.html)
  # for further details.

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error` or `{:error, term}`. To control the
  # response the client receives in that case, [define an error handler in the
  # websocket
  # configuration](https://hexdocs.pm/phoenix/Phoenix.Endpoint.html#socket/3-websocket-configuration).
  #

  @impl true
  def connect(%{"token" => token} = _params, socket, _info) do
    case verify(socket, token) do
      {:ok, email} ->
        socket = assign(socket, email: email, user_token: token)
        {:ok, socket}

      {:error, err} ->
        Logger.error("#{__MODULE__}: error: #{inspect(err)}")
        :error
    end
  end

  def connect(_, _socket, _) do
    Logger.error("#{__MODULE__}: missing params")
    :error
  end

  defp verify(_socket, token) do
    PhxSolid.Token.user_check(token)
    # Phoenix.Token.verify(PhxSolidWeb.Endpoint, "user token", token, max_age: 86_400)
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
