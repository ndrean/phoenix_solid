defmodule PhxSolidWeb.UserLoginLive do
  use PhxSolidWeb, :live_view
  require Logger

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm bg-white">
      <.header class="text-center">
        Sign in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        method="post"
        id="login_form"
        action={~p"/users/log_in"}
        phx-update="ignore"
      >
        <.input
          field={@form[:email]}
          type="email"
          label="Email"
          required
          autocomplete
          phx-debounce="blur"
        />
        <.input field={@form[:password]} type="password" autocomplete label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Signing in..." class="w-full">
            Sign in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>

      <div class="flex justify-center mt-8">
        <div class="align-center flex-row before:flex-1 before:border-1 before:m-auto after:flex-1 after:border-1 after:m-auto">
          OR
        </div>
      </div>

      <.simple_form
        for={@form}
        id="magic_link_form"
        action={~p"/users/log_in?_action=magic_link"}
        phx-update="ignore"
        class="my-0 py-0"
      >
        <.input field={@form[:email]} id="magic" type="email" label="Email" required />
        <:actions>
          <.button class="w-full">
            Send me a link <.icon name="hero-envelope" />
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    # params._csrf_token is passed to the hidden input of the form

    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok,
     assign(socket,
       form: form
     ), temporary_assigns: [form: form]}
  end
end
