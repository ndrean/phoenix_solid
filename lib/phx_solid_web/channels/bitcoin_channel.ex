defmodule PhxSolidWeb.BitcoinChannel do
  use PhxSolidWeb, :channel
  require Logger

  @impl true
  def join("bitcoin", %{"user_token" => user_token}, socket) do
    if authorized?(user_token) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  intercept ["new_btc"]

  def handle_out("new_btc", event, socket) do
    Logger.debug("OUT____________#{event.time}")
    :ok = push(socket, "new_btc_price", event)
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  # @impl true
  # def handle_in("ping", payload, socket) do
  #   {:reply, {:ok, payload}, socket}
  # end

  # # It is also common to receive messages from the client and
  # # broadcast to everyone in the current topic (bitcoin_channel:lobby).
  # @impl true
  # def handle_in("shout", payload, socket) do
  #   broadcast(socket, "shout", payload)
  #   {:noreply, socket}
  # end

  # Add authorization logic here as required.
  defp authorized?(_token) do
    true
  end
end
