defmodule PhxSolid.Streamer do
  use WebSockex
  require Logger
  @url "wss://ws.coincap.io/prices"
  @json_lib Phoenix.json_library()

  defp ws_url(symbol) do
    @url
    |> URI.new!()
    |> URI.append_query(URI.encode_query(%{assets: symbol}))
    |> URI.to_string()
  end

  def start_link(symbol: symbol) do
    symbol
    |> ws_url()
    |> WebSockex.start_link(__MODULE__, %{symbol: symbol})
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected______: #{state.symbol}")
    {:ok, state}
  end

  def handle_disconnect(_conn, state) do
    Logger.warning("Disconnected from #{inspect(ws_url(state.symbol))} for #{state.symbol}")
    {:reconnect, state}
  end

  def handle_frame({:text, msg}, state) do
    case @json_lib.decode(msg) do
      {:ok, event} ->
        process(event)
        {:ok, state}

      {:error, reason} ->
        throw("Error #{inspect(reason)}")
        {:close, state}
    end

    {:ok, state}
  end

  def process(event) do
    event = Map.put(event, :time, DateTime.utc_now())
    :ok = PhxSolidWeb.Endpoint.broadcast_from(self(), "bitcoin", "new_btc", event)
  end
end
