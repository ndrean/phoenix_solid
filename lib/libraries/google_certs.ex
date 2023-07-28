defmodule ElixirGoogleCerts do
  @moduledoc """
  Elixir module to use decipher the ID_token and use the Google One tap.
  It follows the Google SignIn model with the deciphering against Google Certs,
  a double CSRF check, the "iss" check and the "aud" check.

  It exposes the functions

      ElixirGoogleCerts.verified_identity(conn, jwt, g_csrf_token)
      ElixirGoogleCerts.check_identity_v1(jwt)
      ElixirGoogleCerts.check_user(aud, azp)
      ElixirGoogleCerts.check_iss(iss)

  You can use PEM or JWK endpoints. By default, it uses the PEM (v1) endpoint (auth_provider_x509_cert_url).

  ## Example
  You define a POST route and the corresopnding controller:

      # POST /callback_url_one_tap :handle
      def handle(conn, %{"credential" => jwt, "g_csrf_token" => g_csrf_token}) do
        case ElixirGoogleCerts.verified_identity(conn, jwt, g_csrf_token) do
          {:ok, %{email: email, name: name} = profile} -> ...

  For the HTML part, you can get the HTML with Google's [code generator](https://developers.google.com/identity/gsi/web/tools/configurator).

  You need to fill in the `data-login_uri={@cb_url}` in the HTML where the assign `location` is the
  absolute POST route to which Google will send a response.

  You also need to pass the env. variable `GOOGLE_CLIENT_ID` into the assigns to populate
  the dataset `data-client_id={@g_client_id}`,

  In the login page controller:

      cb_url_one_tap =
        Path.join(
          MyApp.Endpoint.url(),
          Application.get_env(:my_app, :g_certs_cb_path)
        ))
      assign(conn, :cb_url, cb_url_one_tap)
      assign(conn, :g_client_id, System.get_env("GOOGLE_CLIENT_ID"))

  You need to inject the following on each page where you need a Google One Tap:

       <script src="https://accounts.google.com/gsi/client" async defer></script>

  ## Dependencies:

      Mix.install([{:jason, "~> 1.4"},{:joken, "~> 2.5"}}])

  ## Configuration

  Set up the env variable:

      GOOGLE_CLIENT_ID.

  Set up the callback path config:
      config :my_app, :g_certs_cb_path, "/path_to_one_tap_cb"

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
  def verified_identity(conn, jwt, g_csrf_token) do
    with :ok <- double_token_check(conn, g_csrf_token),
         {:ok,
          %{
            "aud" => aud,
            "azp" => azp,
            "email" => email,
            "iss" => iss,
            "name" => name,
            "picture" => pic,
            "given_name" => given_name,
            "sub" => sub
          }} <- check_identity_v1(jwt),
         true <- check_user(aud, azp),
         true <- check_iss(iss) do
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
  defp double_token_check(conn, g_csrf_token) do
    case conn.cookies do
      %{"g_csrf_token" => g_cookie} ->
        if g_cookie == g_csrf_token,
          do: :ok,
          else: {:error, "Failed to verify double submit cookie."}

      _ ->
        {:error, "No cookie"}
    end
  end

  # ---- Google post-checking recommendations
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
