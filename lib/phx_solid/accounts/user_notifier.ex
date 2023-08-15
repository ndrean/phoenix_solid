defmodule PhxSolid.Accounts.UserNotifier do
  import Swoosh.Email

  alias PhxSolid.Mailer

  @moduledoc """
  Generate user mails
  """

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"PhxSolid", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Delivers a magic link.
  """
  def deliver_magic_link(user, url) do
    deliver(
      user.email,
      "MagickLink to Sign in to #{Application.get_application(__MODULE__)}, the #{DateTime.utc_now() |> DateTime.to_string()}",
      """
      ==============================

      Hi #{user.email},

      Please use this link to sign in:

      <a href=#{url}>Please click here</a>

      If you didn't request this email, feel free to ignore this.

      ==============================
      """
    )
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    <a href=#{url}>Please click here</a>

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    <a href=#{url}>Please click here</a>

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    <a href=#{url}>Please click here</a>

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
