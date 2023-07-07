defmodule PhxSolid.Token do
  @moduledoc """
  Wrapping Phoenix.Token for mails and users
  """

  @doc """
  Generate a token for a mail given a user and an event

  ### Example

  ```
  iex> token = PhxSolid.Token.mail_generate(%{user_id: 1, event_id: 1})
  ```
  """
  def mail_generate(%{user_id: user_id, event_id: event_id}) do
    Phoenix.Token.sign(
      PhxSolidWeb.Endpoint,
      "mail token",
      "user_id=#{user_id}&event_id=#{event_id}"
    )
  end

  @doc """
  Checks the received token with salt "mail token"

  ### Example
  ```
  iex> {:ok, token} = PhxSolid.Token.mail_check("SFMyNTY.g2gDbQAAABR1c2VyX2lk...")
  ```
  """
  def mail_check(token) do
    case Phoenix.Token.verify(
           PhxSolidWeb.Endpoint,
           "mail token",
           token,
           # 2 months!
           max_age: 5_000_000
         ) do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Generates a token from a user.id

  ### Example

    ```
    iex>id = PhxSolid.User.email("toto@mail.com").id
    iex>token = PhxSolid.user_generate(id)
  ```
  """
  def user_generate(user_id) do
    Phoenix.Token.sign(
      PhxSolidWeb.Endpoint,
      "user token",
      user_id
    )
  end

  @spec user_check(binary) :: {:error, :expired | :invalid | :missing} | {:ok, any}
  @doc """
  Checks the received token with salt "mail token"
    ```
    iex> {:ok, token} = PhxSolid.Token.user_check("SFMyNTY.g2gDbQ...")
    ```
  """
  def user_check(token) do
    case Phoenix.Token.verify(
           PhxSolidWeb.Endpoint,
           "user token",
           token,
           max_age: 86_400
         ) do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, reason}
    end
  end
end
