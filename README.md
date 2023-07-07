# PhxSolid

## Boilerplates

- Phoenix

```bash
mix phx.new phx_solid
```

- SolidJS

```bash
cd phx_solid
npx degit solidjs/templates/js front
```

## Add Google One Tap

To enable **Google One tap**, you need the module `:google_certs` and:

```iex
{:jason, "~> 1.4"},{:joken, "~> 2.5"}
```

You also need:

- to create a project in the <https://console.cloud.google.com>
- you then create credentials as a **web application**
- one tricky point: the "Authorized Javascript origins" should contain **2** fields, with AND without the port.

## Content Seucity Policy

In the `router` module, you will set the CSP as per [Google's recommendations](https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid#content_security_policy)

```iex
plug(
  :put_secure_browser_headers,
  %{"content-security-policy-report-only" => @csp}
)
```

```iex
@csp "
script-src https://accounts.google.com/gsi/client;
frame-src https://accounts.google.com/gsi/;
connect-src https://accounts.google.com/gsi/;
"
```

You will also need to secure the scripts used to pass the token to the `window` object. This can be done with a `nonce`.
