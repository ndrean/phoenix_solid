defmodule PhxSolid do
  @moduledoc """
  Shared functionalities
  """

  require Logger

  def gen_secret do
    Base.url_encode64(:crypto.strong_rand_bytes(16), padding: false)
  end

  # def hostname(), do: PhxSolidWeb.Endpoint.url()

  def g_cb_url() do
    Path.join(
      hostname(),
      Application.get_application(__MODULE__) |> Application.get_env(:g_cb_uri)
    )
  end

  def g_oauth_redirect_url do
    Path.join(
      hostname(),
      Application.get_application(__MODULE__) |> Application.get_env(:g_auth_uri)
    )
  end

  def hostname() do
    :phx_solid
    |> Application.fetch_env!(PhxSolidWeb.Endpoint)
    |> Keyword.fetch!(:url)
    |> Enum.into(%{})
    |> then(fn map ->
      struct(URI.new!(""), map)
      |> URI.to_string()
    end)
  end

  def report_to() do
    case Mix.env() do
      :prod -> "https:#{hostname()}/csp-reports"
      _ -> "http:#{hostname()}/csp-reports"
    end
  end

  def make_nonce(nonce), do: "nonce-#{nonce}"

  def csp_map() do
    Logger.debug("_____________________#{hostname()}")

    script_src =
      "
      '#{make_nonce("123456789")}'
      '#{make_nonce("f35697c2-bf93-418e-a119-8158c69a2b3a")}'
      '#{make_nonce("0bce0d28-93ad-4f3e-9f3f-c1057b0e71b3")}'
      https://accounts.google.com/
      https://connect.facebook.net/
      http:#{hostname()}
      http:#{hostname()}/spa
      https:#{hostname()}
      "

    frame_src = "https://accounts.google.com/"

    connect_src =
      "https://accounts.google.com/
      https://www.facebook.com/
      wss:#{hostname()}
      ws:#{hostname()}"

    %{
      "base-uri" => "'self'",
      "script-src" => "'self' " <> script_src,
      "frame-src" => "'self' " <> frame_src,
      "connect-src" => "'self' " <> connect_src,
      "report-to" => "#{report_to()}"
    }
  end

  def csp() do
    csp_map()
    |> Enum.reduce("", fn {k, v}, acc ->
      acc <> "#{k} #{v |> String.replace("\n", " ")};"
    end)
    |> String.trim()
  end

  def add_nonce_to_csp_at(key, nonce) when key in ["script-src", "frame-src", "connect-src"] do
    Map.update!(csp_map(), "key", fn st -> st <> make_nonce(nonce) end)
  end
end
