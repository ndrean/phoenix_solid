# PhxSolid

We present a Phoenix app that starts are a normal SSR app and renders an SPA.

Once authenticated with a sign-in, the user can access to the SPA, powered by SolidJS.

This SPA will communicate with this node via sockets, more precisely over a channel. The node will save the state of the SPA.

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

## A word about the "context" pattern in the SPA

A functional component is a function that takes some props and renders a function that renders some HTML. Any change in the state should, via the props, run this function and update the DOM.

```jsx
const Component = (props)=> {()=> HTML stuff(props)}
<Component ...>{props.children}</Component>
```

The "context" pattern is a parametrisation of this functional component. We use it like this:

```jsx
const component = (context) => (props)=> {()=> HTML stuff(contxt, props)}
const Component = component(context)

<Component ...>{props.children} </Component>
```

We can put in the "context" object anything we want to share. It can be a global state, CSS themes...
The component will not be reactive to the context: it will however read it whenever it renders.

This is useful when you navigate in an SPA. Whenever you visit a new page with components, these components' functions will run, thus read the context. If we change a state in a page and pass it to the context, and if another component in this new page uses this state, it will render update-to-date data.

This simple pattern saves from having to use complicated global state managers. However, if you have several intricated components on the same page, then the context pattern is useless and you still need a global state for this page to render the components.

## Phoenix renders the SPA

```elixir
# config.exs
config :phx_solid,
  google_client_id: System.get_env("GOOGLE_CLIENT_ID"),
  google_client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
  google_scope: "profile email",
  spa_dir: "./priv/static/spa/"
```

### Static files config

- `Vite`: use `base: "/spa" to pass the correct path in the build.

```js
export default defineConfig({
  plugins: [solidPlugin()],
  base: "/spa/",
  build: {
    target: "esnext",
  },
});
```

- `Phoenix`: in the module "app_web.ex", add the folder "spa" to "static_paths"

```elixir
def static_paths, do: ~w(assets fonts images favicon.ico robots.txt) ++ ["spa"]
```

### Build and copy the SPA into "priv/static"

We will compile the JS/CSS and copy the files into the folder `Application.compile_env!(:phx_solid, :spa_dir)`.

We set up a "mix task" to compile and copy. It uses the behaviour "Mix.Task" and provides a `call/1` function to run these tasks.

```bash
mix spa
```

## Add Google One Tap

To enable **Google One tap**, you need the module `:google_certs` and add dependencies:

```elixir
{:jason, "~> 1.4"},{:joken, "~> 2.5"}
```

You will credentials from Google.

- create a project in the <https://console.cloud.google.com>
- then create credentials as a **web application**
- ⚠️ the "Authorized Javascript origins" should contain **2** fields, with AND without the port.

You set up a "one_tap_controller". It is a POST endpoint and will receive a response from Google. It will set a `user_token` and the users' `profile` in the session, and redirect to a "welcome" page.

<img width="502" alt="Screenshot 2023-07-07 at 16 51 37" src="https://github.com/ndrean/phoenix_solid/assets/6793008/b07428c8-1722-49f9-9003-6f9b513eb1e4">

### Source .env

```bash
.env
export GOOGLE_CLIENT_ID=xxx
export GOOGLE_CLIENT_SECRET=xxx
```

Do:

```bash
source .env
```

### Content Secuity Policy

In the `router` module, you will set the CSP as per [Google's recommendations](https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid#content_security_policy)

```elixir
plug(
  :put_secure_browser_headers,
  %{"content-security-policy-report-only" => @csp}
)
```

```elixir
@csp "
script-src https://accounts.google.com/gsi/client;
frame-src https://accounts.google.com/gsi/;
connect-src https://accounts.google.com/gsi/;
"
```

You will also need to secure the scripts used to pass the token to the `window` object. This can be done with a `nonce`.

## SPA rendering

The compiled files are located in the "priv/state/spa" (declared in our "config.exs").

We set up an endpoint "/spa" to render the SPA. The corresponding controller will read the compiled "index.html" + associated JS + CSS files and render with `Phoenix.Controller.html(conn, file)`.

We also inject a `user_token` into this file, attached to the `window` object. It will be run as a script for the DOM to read it. This token is generated using the profile's email (collected with our **sign in** in the "one_tap_controller") and `App.Endpoint` (since `conn` won't be available):

```elixir
Phoenix.Token.sign(PhxSolidWeb.Endpoint,"user_token", email )
```

## Communication between the SPA and Phoenix

Even if the SPA is fully functional, we are just rendering HTML so when we navigate back and forth between Phoenix and the SPA, the state of the SPA is lost.

In order to save the _state of the SPA_, we use channels through the `Socket` object

### The `socket`

It is an object that holds the WS. We will set up the socket SPA side and server side. We generate the 2 files - server & client - needed to handle bith sides of the socket and install the npm package [phoenix](https://www.npmjs.com/package/phoenix) in the SPA.

```bash
mix phx.gen.socket User
cd front && pnpm i phoenix
```

#### Client-side

In the SPA's "index.jsx" file (where we `render`), we instantiate the socket connection with the `Socket` object and pass along the `user_token` read from the DOM. It will be available in the query string of the "ws", hence params, and is received server-side to authenticate and thus permit the connection.

```js
import { Socket } from "phoenix";

const socket = new Socket("/socket", {
  params: { token: window.userToken },
});
socket.connect();
export { socket };
```

We also built a helper `useChannel`. It attaches a channel to the socket with a topic and returns the channel, ready to be used (`.on`, `.push`). Use it every time you need to communicate with the backend. It has a cleaning stage in its life cycle.

#### Server-side

We add to our "endpoint.ex":

```elixir
# endpoint.ex
socket "/socket", PhxSolidWeb.UserSocket,
  websocket: true,
  longpoll: false
```

Server-side, the "user_socket.ex" module is invoked and receives the "user_token" in the params. We verify it:

```elixir
Phoenix.Token.verify(PhxSolidWeb.Endpoint, "user token", token, max_age: 86_400)
```

We used `App.Endpoint` since `conn` is not available.

The connection should be fine now.

## Channels

A channel is an Elixir process derived from a Genserver: it is therefore capable of emitting and receiving messages.
A channel is uniquely identified by a string and attached to the `socket` which accepts a list of channels.

```js
const socket = new Socket(...)
[...]
const ctxCh = socket.channel("ctx", {})
const countCh = socket.channel("counter", {})
```

The channels are set up to persist state within the SPA.

- Whenever we `push` data through a channel client-side, its alter ego server-side will receive it in a callback `handle_in`.
- we can push data from the server to the client through the socket with a `broadcast` related to a topic. The client will receive it with the listener `mychannel.on`.

To set up a channel, use the generator:

```bash
mix phx.gen.channel Counter
```

## State persistence

We could set up a Genserver, an Agent, an ETS table, a Redis session or use the database. If the app is distributed, most probably Redis or the database should be used.

## Serving static files

We could further reduce the load on the Phoenix backend by using a reverse proxy (Nginx > Caddy) with cache control. It would serve the static files and pass the WS connections and HTTP connections to the backend.

See `nginx` conf. Run below to reload, test and set the local "config.conf" file.

```bash
nginx -s reload -c $(pwd)/config.conf -t
```
