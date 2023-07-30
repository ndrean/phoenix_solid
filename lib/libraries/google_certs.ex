defmodule ElixirGoogleCerts do
  @moduledoc """
  Elixir module to use Google One tap from a controller.
  It follows the Google SignIn model with the deciphering against Google public keys, a nonce,
  a double CSRF check, the "iss" check and the "aud" check.

  It exposes the following functions:

      ElixirGoogleCerts.verified_identity(%{cookie, jwt, g_csrf_token, g_nonce})
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

      # POST /users/one_tap :handle
      def handle(conn, %{"credential" => jwt, "g_csrf_token" => g_csrf_token}) do
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

  @doc """
  Takes the conn, the JWT token, the g_csrf_token returned by Google as params to the POST endpoint.
  It renders `{:ok, profil}` or `{:error, reason}`.

  ## Example

      iex> def handle(conn, %{"credential" => jwt, "g_csrf_token" => g_csrf_token}) do
      with {:ok, profile} <- ElixirGoogleCerts.verified_identity(conn, jwt, g_csrf_token) do
          %{email: email, name: _name, google_id: _sub, picture: _pic} = profile
          ...
      end

  """
  def verified_identity(%{cookie: cookie, jwt: jwt, g_csrf_token: g_csrf_token, g_nonce: g_nonce}) do
    with true <- double_token_check(cookie, g_csrf_token),
         {:ok,
          %{
            "aud" => aud,
            "azp" => azp,
            "email" => email,
            "iss" => iss,
            "name" => name,
            "picture" => pic,
            "given_name" => given_name,
            "sub" => sub,
            "nonce" => nonce
          }} <-
           check_identity_v1(jwt),
         true <- check_user(aud, azp),
         true <- check_iss(iss),
         true <- check_nonce(nonce, g_nonce) do
      {:ok, %{email: email, name: name, google_id: sub, picture: pic, given_name: given_name}}
    else
      {:error, msg} -> {:error, msg}
      false -> {:error, :wrong_check}
    end
  end

  def check_identity_v1(jwt) do
    case Joken.peek_header(jwt) do
      {:error, msg} ->
        {:error, msg}

      {:ok, %{"alg" => alg, "kid" => kid, "typ" => "JWT"}} ->
        case fetch(@g_certs1_url) do
          {:ok, %{body: body}} ->
            {true, %{fields: fields}, _} =
              body
              |> Jason.decode!()
              # |> Jsonrs.decode!()
              |> Map.get(kid)
              |> JOSE.JWK.from_pem()
              |> JOSE.JWT.verify_strict([alg], jwt)

            {:ok, fields}

          {:error, msg} ->
            {:error, msg}
        end
    end
  end

  def check_identity_v3(jwt) do
    case Joken.peek_header(jwt) do
      {:error, msg} ->
        {:error, msg}

      {:ok, %{"kid" => kid, "alg" => alg}} ->
        case fetch(@g_certs3_url) do
          {:ok, %{body: body}} ->
            %{"keys" => certs} = Jason.decode!(body)
            # %{"keys" => certs} = Jsonrs.decode!(body)
            cert = Enum.find(certs, fn cert -> cert["kid"] == kid end)
            signer = Joken.Signer.create(alg, cert)
            Joken.verify(jwt, signer, [])

          {:error, msg} ->
            {:error, msg}
        end
    end
  end

  # decouple from HTTP client
  def fetch(url) do
    case :httpc.request(:get, {~c"#{url}", []}, [], []) do
      {:ok, {{_version, 200, _}, _headers, body}} ->
        {:ok, %{body: body}}

      error ->
        {:error, inspect(error)}
    end
  end

  # token in body is equal to received cookie
  def double_token_check(cookie, g_csrf_token), do: cookie === g_csrf_token

  # ---- Google post-checking recommendations
  def check_nonce(nonce, g_nonce), do: nonce === g_nonce

  @doc """
  Confirm the Google_Client_ID
  """
  def check_user(aud, azp) do
    aud == aud() || azp == aud()
  end

  @doc """
  Confirm issuer is Google Accounts
  """
  def check_iss(iss), do: iss == @iss
  defp aud, do: System.get_env("GOOGLE_CLIENT_ID")
end
