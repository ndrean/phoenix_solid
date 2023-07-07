defmodule ElixirGoogleCerts do
  @g_certs3_url "https://www.googleapis.com/oauth2/v3/certs"
  @iss "https://accounts.google.com"

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
          }} <- check_identity(jwt),
         true <- check_user(aud, azp),
         true <- check_iss(iss) do
      {:ok, %{email: email, name: name, google_id: sub, picture: pic, given_name: given_name}}
    else
      {:error, msg} -> {:error, msg}
      false -> {:error, :wrong_check}
    end
  end

  defp check_identity(jwt) do
    case Joken.peek_header(jwt) do
      {:error, msg} ->
        {:error, msg}

      {:ok, %{"kid" => kid, "alg" => alg}} ->
        with {:ok, %{body: body}} <-
               Finch.build(:get, @g_certs3_url)
               |> Finch.request(PhxSolid.Finch) do
          IO.inspect(body, label: "body")
          %{"keys" => certs} = Jason.decode!(body)
          cert = Enum.find(certs, fn cert -> cert["kid"] == kid end)
          signer = Joken.Signer.create(alg, cert)
          Joken.verify(jwt, signer, [])
        else
          {:error, msg} -> {:error, msg}
        end
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
  defp check_user(aud, azp) do
    aud == aud() || azp == aud()
  end

  defp check_iss(iss), do: iss == @iss
  defp aud, do: System.get_env("GOOGLE_CLIENT_ID")
end
