defmodule PhxSolidWeb.BitcoinChannel do
  use PhxSolidWeb, :channel
  require Logger

  @moduledoc """
  Websocket connection wrapper. Receives the Bitcoin price from the Streamer module
  and puts it into the socket for the front-end.
  """

  @impl true
  def join("bitcoin", %{"user_token" => user_token}, socket) do
    case authorized?(user_token) do
      true ->
        {:ok, socket}

      false ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  intercept ["new_bitcoin"]

  def handle_out("new_bitcoin", event, socket) do
    Logger.debug("OUT_____")
    :ok = push(socket, "new_btc_price", event)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_token) do
    true
  end
end
