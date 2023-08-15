defmodule ElixirGoogleCerts do
  @moduledoc """
  Elixir module to use Google One tap from a controller.
  It follows the Google SignIn model with the deciphering against Google public keys, a nonce,
  a double CSRF check, the "iss" check and the "aud" check.

  It exposes the following functions:

      ElixirGoogleCerts.verified_identity(%{jwt, g_nonce})
      ElixirGoogleCerts.check_identity_v1(jwt)
      ElixirGoogleCerts.check_identity_v3(jwt)
      ElixirGoogleCerts.check_user(aud, azp)
      ElixirGoogleCerts.check_iss(iss)

  You can use PEM or JWK endpoints. By default, it uses the PEM (v1) endpoint (auth_provider_x509_cert_url).

  ## Example

  You insert HTML part in your login page. It is composed of a script tag and HTML. The script is:

       <script src="https://accounts.google.com/gsi/client" async defer></script>

  You can get the HTML with Google's [code generator](https://developers.google.com/identity/gsi/web/tools/configurator).

  You populate this HTML rendered from your login page controller with the following assigns:

  - `data-nonce={@g_nonce}` as per <https://developers.google.com/identity/gsi/web/reference/html-reference#data-nonce>
  - `data-client_id={@g_client_id}` as per <https://developers.google.com/identity/gsi/web/reference/html-reference#data-client_id>
  - `data-login_uri={@location}` as per <https://developers.google.com/identity/gsi/web/reference/html-reference#data-login_uri>


  You generate a nonce and save it in the session. For example, you can use:

      g_nonce = Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)

  You pass the env. variable `GOOGLE_CLIENT_ID` (or from the config) as the assign `g_client_id`.

  The `location` assign is the absolute URL for google to POST a response to your app. It is used in _three_
  places:
  - passed to Google via the config (or env. variable, see set up below)
  - in your router as a POST endpoint.
  - in the project set up in the Google library API


  The router:

      #router.ex
      pipeline :api do
        plug :accepts, ["json"]
        post("/users/one_tap", MyAppdWeb.OneTapController, :handle)

  The login controller renders the Google One Tap button. You generate a cryptic token "g_nonce".

      #login_controller.ex
      def login(conn, _) do

        g_nonce =  Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)

        location =
          Path.join(
            MyApp.Endpoint.url(),
            Application.get_env(:my_app, :g_certs_cb_path)
          )
        ...
        conn
        |> fetch_session()
        |> put_session(:g_nonce, g_nonce)
        |> assign(conn, :location, location)
        |> assign(conn, :g_client_id, System.get_env("GOOGLE_CLIENT_ID"))
        ...
      end

  The callback controller receives the response posted by Google and returns the profile if successful.

  You use a plug `:check_csrf` to check if the emitted csrf saved in `conn.cookies` is equal to the one received in body
  of the HTTP POST request.


      # POST /users/one_tap :handle
      plug :check_csrf
      def handle(conn, %{"credential" => jwt) do
        case ElixirGoogleCerts.verified_identity(%{
            cookie: cookie,
            jwt: jwt,
            g_csrf_token: g_csrf_token,
            g_nonce: g_nonce
          }) do
        {:ok, %{email: email, name: name} = profile} -> ...


  ## Dependencies:

      Mix.install([{:jason, "~> 1.4"},{:joken, "~> 2.5"}}])

  ## Configuration

  Set up the env variables or a config:

      #.env
      GOOGLE_CLIENT_ID.

      #config.exs
      config :my_app,
        g_certs_cb_path: "/users/one_tap",
        g_client_id: System.get_env("GOOGLE_CLIENT_ID")
        g_client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

  """

  @g_certs1_url "https://www.googleapis.com/oauth2/v1/certs"
  @g_certs3_url "https://www.googleapis.com/oauth2/v3/certs"
  @iss "https://accounts.google.com"

  @json_lib Phoenix.json_library()

  # Application.compile_env(:phoenix, :json_library)

  @doc """
  This is run after the plug "check_csrf".

  It takes a map with the JWT token and a nonce. It checks that
  the received nonce is equal to the emitted one, and deciphers the JWT
  against Google public key (PEM or JWK).


        ElixirGoogleCerts.verfified_identity(%{n
          once: emitted_nonce,
          jwt: received_jwt
        })

  It returns `{:ok, profil}` or `{:error, reason}`.
  """
  def verified_identity(%{jwt: jwt, g_nonce: g_nonce}) do
    with {:ok,
          %{
            "sub" => sub,
            "name" => name,
            "email" => email,
            "given_name" => given_name
          } = claims} <-
           check_identity_v1(jwt),
         true <- check_iss(claims["iss"]),
         true <- check_user(claims["aud"], claims["azp"]),
         true <- check_nonce(claims["nonce"], g_nonce) do
      {:ok, %{email: email, name: name, google_id: sub, given_name: given_name}}
    else
      {:error, msg} -> {:error, msg}
      false -> {:error, :wrong_check}
    end
  end

  @doc """
  Uses the Google Public key in PEM format. Takes the JWT and returns `{:ok, profile}` or `{:error, reason}`
  """
  def check_identity_v1(jwt) do
    with {:ok, %{"kid" => kid, "alg" => alg}} <- Joken.peek_header(jwt),
         {:ok, %{body: body}} <- fetch(@g_certs1_url) do
      {true, %{fields: fields}, _} =
        body
        |> @json_lib.decode!()
        |> Map.get(kid)
        |> JOSE.JWK.from_pem()
        |> JOSE.JWT.verify_strict([alg], jwt)

      {:ok, fields}
    else
      {:error, reason} -> {:error, inspect(reason)}
    end
  end

  @doc """
  Uses the Google Public key JWK. Takes the JWT and returns `{:ok, profile}` or `{:error, reason}`
  """
  def check_identity_v3(jwt) do
    with {:ok, %{"kid" => kid, "alg" => alg}} <- Joken.peek_header(jwt),
         {:ok, %{body: body}} <- fetch(@g_certs3_url) do
      %{"keys" => certs} = @json_lib.decode!(body)
      cert = Enum.find(certs, fn cert -> cert["kid"] == kid end)
      signer = Joken.Signer.create(alg, cert)
      Joken.verify(jwt, signer, [])
    else
      {:error, reason} -> {:error, inspect(reason)}
    end
  end

  # decouple from HTTP client
  defp fetch(url) do
    case :httpc.request(:get, {~c"#{url}", []}, [], []) do
      {:ok, {{_version, 200, _}, _headers, body}} ->
        {:ok, %{body: body}}

      error ->
        {:error, inspect(error)}
    end
  end

  # ---- Google post-checking recommendations
  @doc """
  Checks the received nonce against the one set in the HTML.

  Returns `true` or `false`.
  """
  def check_nonce(nonce, g_nonce), do: nonce === g_nonce

  @doc """
  Confirm the received Google_Client_ID against the one stored in the app.

  Returns `true` or `false`.
  """
  def check_user(aud, azp) do
    aud == aud() || azp == aud()
  end

  @doc """
  Confirm the received issuer is the one stored in the app.

  Returns `true` or `false`.
  """
  def check_iss(iss), do: iss == @iss
  defp aud, do: System.get_env("GOOGLE_CLIENT_ID")
end
