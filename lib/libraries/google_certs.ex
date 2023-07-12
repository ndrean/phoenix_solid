defmodule ElixirGoogleCerts do
  @moduledoc """
  Elixir module to use Google One tap. You can use PEM or JWK endpoints. By default, it uses the JWK (v3) endpoint.

  Dependencies on `Jason` and `Finch`. You can change the HTTP client in the function `fetch`.
  """
  # auth_provider_x509_cert_url
  @g_certs1_url "https://www.googleapis.com/oauth2/v1/certs"
  # @g_certs3_url "https://www.googleapis.com/oauth2/v3/certs"
  @iss "https://accounts.google.com"

  @doc """
  Takes the conn, the JWT token, the g_csrf_token returned by Google as params to the POST endpoint and the HTTP client name.
  It renders `{:ok, profil}` or `{:error, reason}`.

  ## Example

      iex> def handle(conn, %{"credential" => jwt, "g_csrf_token" => g_csrf_token}) do
      with {:ok, profile} <- ElixirGoogleCerts.verified_identity(conn, jwt, g_csrf_token, MyApp.Finch) do
          %{email: email, name: _name, google_id: _sub, picture: _pic} = profile
          ...
      end

  """
  def verified_identity(conn, jwt, g_csrf_token, name) do
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
          }} <- check_identity_v1(jwt, name),
         true <- check_user(aud, azp),
         true <- check_iss(iss) do
      {:ok, %{email: email, name: name, google_id: sub, picture: pic, given_name: given_name}}
    else
      {:error, msg} -> {:error, msg}
      false -> {:error, :wrong_check}
    end
  end

  defp check_identity_v1(jwt, name) do
    case Joken.peek_header(jwt) do
      {:error, msg} ->
        {:error, msg}

      {:ok, %{"alg" => alg, "kid" => kid, "typ" => "JWT"}} ->
        with {:ok, %{body: body}} <- fetch(@g_certs1_url, name) do
          {true, %{fields: fields}, _} =
            body
            |> Jason.decode!()
            |> Map.get(kid)
            |> JOSE.JWK.from_pem()
            |> JOSE.JWT.verify_strict([alg], jwt)

          {:ok, fields}
        else
          {:error, msg} -> {:error, msg}
        end
    end
  end

  # defp check_identity_v3(jwt, name) do
  #   case Joken.peek_header(jwt) do
  #     {:error, msg} ->
  #       {:error, msg}

  #     {:ok, %{"kid" => kid, "alg" => alg}} ->
  #       with {:ok, %{body: body}} <-
  #              fetch(@g_certs3_url, name) do
  #         %{"keys" => certs} = Jason.decode!(body)
  #         cert = Enum.find(certs, fn cert -> cert["kid"] == kid end)
  #         signer = Joken.Signer.create(alg, cert)
  #         Joken.verify(jwt, signer, [])
  #       else
  #         {:error, msg} -> {:error, msg}
  #       end
  #   end
  # end

  # decouple from HTTP client
  defp fetch(url, name) do
    Finch.build(:get, url)
    |> Finch.request(name)
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
  defp check_user(aud, azp) do
    aud == aud() || azp == aud()
  end

  defp check_iss(iss), do: iss == @iss
  defp aud, do: System.get_env("GOOGLE_CLIENT_ID")
end
