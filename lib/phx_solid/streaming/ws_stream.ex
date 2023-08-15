defmodule PhxSolid.Stream do
  @moduledoc """
  Wrapper to start a websocket client connection for a given symbol
  """
  def new(symbol) do
    {:ok, _pid} = PhxSolid.Streamer.start_link(symbol: symbol)
  end

  def stop(pid) do
    Process.exit(pid, :stop)
  end

  def start_sup(symbol) do
    DynamicSupervisor.start_child(MyDynSup, {PhxSolid.Streamer, [symbol: symbol]})
  end

  def stop_sup(pid) do
    DynamicSupervisor.terminate_child(MyDynSup, pid)
  end
end
