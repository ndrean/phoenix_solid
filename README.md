# PhxSolid

The project is to include a [SolidJS](https://www.solidjs.com/) app in a Phoenix app. It will render two versions of an SPA: one embedded with a "hook" in a Liveview, and the other rendered in a separate page.

It starts as a normal Phoenix SSR app with a login to authenticate the user. We used a simple Google One Tap login.

The SPA will commmunicate with the Phoenix node through an authenticated websocket. Channels will be set up to maintain the state of the SPA as well as push information from the backend to the SPA.

What are the differences between the two options?

- the full page is built with `Vite` (with Esbuild and Rollup). The compilation of the fullpage code is a custom process, run via a `Task`. The embedded version is compiled with `Esbuild` via a modified `mix assets.deploy`: you set up a custom "build" version of Esbuild. Rollup is _more performant_ than Esbuild to minimize the size of the bundles.
- to use authenticated websockets with an authneticated user, we need to [adapt the documentation](https://hexdocs.pm/phoenix/channels.html#using-token-authentication). We firstly generate a `Phoenix.Token`.
  - when we use the embedded SPA, we pass this "user token" into the `conn.assigns` from a Phoenix controller and it will be available in the HTML "root.html.heex" template. It is hard coded, attached to the `window` object so Javascript is able to read it. For the backend Liveview, we pass it into a session so available in the `Phoenix.LiveView.mount/3` callback. The embedded version will be declared via a dataset `phx-hook` and rendered in a dedicated component.
  - For the fullpage version, a controller will `Plug.Conn.send_resp` the compiled "index.html" file of the SPA. In the controller, we hard code the token (available in the "conn.assigns") into this file. Then Javascript will be able to read it and use it.
- both versions will use the `_csrf_token` for the main `Socket` websocket, renewed each time we mount a new Liveview.

## "hooked" SPA

### Esbuild

You set up a custom `Esbuild` configuration to use the [custom plugin `solidPlugin`](https://github.com/amoutonbrady/esbuild-plugin-solid). Since SolidJS uses JSX for templating, we have to be sure Esbuild compiles the JSX files for **SolidJS**.

The Phoenix documentation explains [how to add a plugin](https://hexdocs.pm/phoenix/asset_management.html#esbuild-plugins). Esbuild will build the assets when we run the following function:

```js
// build.js
import { context, build } from "esbuild";
import { solidPlugin } from "esbuild-plugin-solid";

const args = process.argv.slice(2);
const watch = args.includes("--watch");
const deploy = args.includes("--deploy");

// Define esbuild options
let opts = {
  entryPoints: ["js/app.js", "js/solidAppHook.js"],
  bundle: true,
  logLevel: "info",
  target: "es2021",
  outdir: "../priv/static/assets",
  external: ["*.css", "fonts/*", "images/*"],
  loader: { ".js": "jsx", ".svg": "file" },
  plugins: [solidPlugin()],
  format: "esm",
};

if (deploy) {
  opts = {
    ...opts,
    minify: true,
    splitting: true,
  };
}

if (watch) {
  opts = {
    ...opts,
    sourcemap: "inline",
  };

  context(opts)
    .then((ctx) => {
      ctx.watch();
    })
    .catch((_error) => {
      process.exit(1);
    });
} else {
  build(opts);
}
```

To take advantage of the code splitting, pass `splitting: true` so that the deploy `node build.js --deploy` will split the code into chunks.

The "config.exs" file will only contain the required version:

```elixir
# config.exs
config :esbuild,
  version: "0.17.11"
```

To run `build.s`, the documentation explains to modify the alias `mix assets.deploy` defined in the Mix.Project: you run `node build.js --deploy` in the "/assets" folder.

```elixir
"assets.deploy": [
  "tailwind default --minify",
  "cmd --cd assets node build.js --deploy",
  "phx.digest"
]
```

You will also need to:

- check how to [configure Tailwind with Phoenix](https://tailwindcss.com/docs/guides/phoenix)
- add "type=module" in the "my_app_web/components/layouts/root.html.heex" file as code splitting works with ESM (using `import`).

```html
<script defer phx-track-static type="module" type="text/javascript" src={~p"/assets/app.js"}></script>
```

- declare you are using `"type": "module"` in "/assets/package.json"

```js
//...
"type": "module",
"dependencies": {
   "@solidjs/router": "^0.8.2",
   "bau-solidcss": "^0.1.14",
   "phoenix": "file:../deps/phoenix",
   "phoenix_html": "file:../deps/phoenix_html",
   "phoenix_live_view": "file:../deps/phoenix_live_view",
   "solid-js": "^1.7.7",
   "topbar": "^2.0.1"
 },
 "devDependencies": {
   "esbuild": "^0.18.11",
   "esbuild-plugin-solid": "^0.5.0",
   "@tailwindcss/forms": "^0.5.4",
   "tailwindcss": "^3.3.3"
 }
```

#### Mount an SPA as a hook to a Liveview

We will mount a LiveView and render a component. This component has a "hook" attached, declared via a dataset `phx-hook="solidAppHook"` in the HTML. This hook references the SPA Javascript code.

```elixir
use Phoenix.Component
def display(assigns) do
  ~H"""
  <div id="solid" phx-hook="SolidAppHook" phx-update="ignore"></div>
  """
end
```

We will attach an object "hook" to the `LiveSocket` (the one authenticated with the `_csrf_token`).

```js
//app.js
import { Socket } from "phoenix";

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: { SolidAppHook },
});
```

The code of the hook:

```js
//SolidAppHook.js
const SolidAppHook = {
  mounted(){import(...). then((App)=> render(...)}
}
```

You set up a "user_socket" and authenticate it in the backend with the "user token". We will attach a `channel`to have two ways communication between the front and the back.

## Navigation with Phoenix/Liveview

Once you are authenticated via the sign-in, you are redirected to a Liveview. We set up a [tab like navigation](https://dev.to/ndrean/breadcumbs-with-phoenix-liveview-2d40) where you can choose to render the SPA in a full page or run the embedded SPA.

The full page SPA will be the "built" version and be rendered by `Plug.Conn.send_resp`.

An `on mount` function is run on each mount of the liveview as [recommended by the doc](https://hexdocs.pm/phoenix_live_view/security-model.html#mounting-considerations).

## **non hook** SPA

The boilerplate is:

```bash
cd phx_solid
npx degit solidjs/templates/js front
```

### Set up

- `Vite`: use `base: "/spa"` to pass the correct path in the build.

```js
export default defineConfig({
  plugins: [solidPlugin()],
  base: "/spa/",
         ^^^
  build: {
    target: "esnext",
  },
});
```

- modify "/front/src/index.html". In this file, add a "title" in the "head" tag. This will help to insert programmaticaly the "user_token" in this file as seen further down.

```html
<title>Solid App</title>
```

- `Phoenix`: in the module "app_web.ex", add the folder "spa" to "static_paths" so the "endpoint.ex" gets the correct config through `plug Plug.Static, only: PhxSolidWeb.static_paths()`

```elixir
  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt) ++ ["spa"]
```

### Build the rendered SPA

We will compile the "front" files and copy them into the folder "priv/static/spa". We set up a [mix task](https://hexdocs.pm/mix/Mix.html) for this.

```bash
mix spa
```

### Render the "non-hook" SPA

The route "/spa" will call the controller "spa_controller". It reads the compiled "index.html" file from the "priv/static/spa" folder and adds the "user_token" inside a "script" tag. To put this into the "head" tag, we added `<title>Solid app</title>` in the "index.html" file of the SPA. When we read the file line by line and encounter this particular line, we add the "script" tag" with the "user_token" value from the session. We end the controller with a `Plug.Conn.send_resp`.

Note that the file path is defined by the function below. We need to add `Application.app_dir(:phx_solid` for the **mix release** version to find this file.

```elixir
defp index_html do
  Application.app_dir(:phx_solid) <> "/" <>
  Application.get_env(:phx_solid, :spa_dir)
  <>  "index.html"
end
```

### Return from SPA to Phoenix

The SPA offers a navigation, in particular a link to return to Phoenix. We need to pass this via env variables. This is done with `Vite` with `import.meta.env.VITE_XXX`. Vite already has `dotenv` installed. All this is [explained by the doc](https://vitejs.dev/guide/env-and-mode.html#env-files). You can use just like this to reference the URL to which we want to navigate back.

```js
<a href={import.meta.env.VITE_RETURN_URL}>...</a>
```

```bash
# .env
VITE_RETURN_URL=http://localhost:4000/welcome
```

## User token

We generate a token per user after the sign-in.

```elixir
Phoenix.Token.sign(PhxSolidWeb.Endpoint,"user_token", id )
```

We can check the validity of the websocket connection since we will check the token with the alter ego function `Phoenix.Token.verify`

## Passing data between the SPA and Phoenix

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

We also built a helper `useChannel`. It attaches a channel to the socket with a topic and returns the channel, ready to be used (`.on`, `.push`). Use it every time you need to create a channel and communicate with the backend. It has a cleaning stage in its life cycle.

```js
import { onCleanup } from "solid-js";

export default function useChannel(socket, topic) {
  if (!socket) return null;
  const channel = socket.channel(topic, { user_token: window.userToken });
  channel
    .join()
    .receive("ok", () => {
      console.log("Joined successfully");
    })
    .receive("error", (resp) => {
      console.log("Unable to join", resp);
    });
  onCleanup(() => {
    console.log("closing channel");
    channel.leave();
  });

  return channel;
}
```

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

- Whenever we `push` data through a channel client-side, its alter ego server-side will receive it in a callback `handle_in`.
- we can push data from the server to the client through the socket with a `broadcast` related to a topic. The client will receive it with the listener `mychannel.on`.

To set up a channel, use the generator:

```bash
mix phx.gen.channel Counter
```

## State persistence

We could set up a Genserver, an Agent, an ETS table, a Redis session or use the database. If the app is distributed, most probably Redis or the database should be used.

## Misc

### Add Google One Tap

To enable **Google One tap**, there is a module `:google_certs`. It needs the dependencies

```elixir
{:jason, "~> 1.4"},{:joken, "~> 2.5"}
```

`Joken` will bring in `JOSE` which is used to decrypt the PEM version.

You will need credentials from Google.

- create a project in the <https://console.cloud.google.com>
- then create credentials as a **web application**
- ⚠️ the "Authorized Javascript origins" should contain **2** fields, with AND without the port.

You set up a "one_tap_controller". It is a POST endpoint and will receive a response from Google. It will set a `user_token` and the users' `profile` in the session, and redirect to a "welcome" page.

<img width="502" alt="Screenshot 2023-07-07 at 16 51 37" src="https://github.com/ndrean/phoenix_solid/assets/6793008/b07428c8-1722-49f9-9003-6f9b513eb1e4">

#### Source .env

Don't forget to add the credentials in ".env".

```bash
# .env-dev
export GOOGLE_CLIENT_ID=xxx
export GOOGLE_CLIENT_SECRET=xxx
```

and source them:

```bash
source .env-dev
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

### Serving static files

We could further reduce the load on the Phoenix backend by using a reverse proxy (Nginx > Caddy) with cache control. It would serve the static files and pass the WS connections and HTTP connections to the backend.

#### Nginx

The easiest way to use Nginx is to use a container running an NGINX image. We can mount the config file and the static files inside it.

> Relative paths in Nginx are resolved based on the Nginx installation directory, not the current working directory or the location of the configuration file.
> It will serve the static files and reverse proxy the app.

Create a Dockerfile that takes an NGINX image and copy the static files "priv/static/assets" and "/priv/static/spa" into the folder "/usr/share/nginx/".

```bash
docker build -t webserver -f ./docker/nginx/Dockerfile .
docker run -it --rm -p 80:80 --name web -v $(pwd)/solid.conf:/etc/nginx/conf.d/default.conf webserver
```

The image will use the underlying `entrypoint` and `cmd` provided by the NGINX image. Enter in it and check:

```bash
docker exec -it web bash
ls /usr/share/nginx/
```

### Notes on SQLITE

Gist: <https://gist.github.com/mcrumm/98059439c673be7e0484589162a54a01>

- check after migration

```bash
mix ecto.create
mix ecto.gen.migration create_users_table
mix ecto.migrate
sqlite3 phx_solid .schema
```

- [migration in a release without Mix installed](https://hexdocs.pm/phoenix/releases.html#ecto-migrations-and-custom-commands): "release.ex"

- [upserts with SQLite3](https://www.sqlite.org/lang_UPSERT.html) works when the target field has a unique constrainte (`create unique_index` in the migration):

```elixir
Repo.insert!(
  %User{email: email, name: name, logs: 1},
  conflict_target: [:email],
  on_conflict: [
    inc: [logs: 1],
    set: [updated_at: DateTime.utc_now()]
  ]
)
```

### CSS Typewritter

Typewritter effect: <https://dev.to/lazysock/make-a-typewriter-effect-with-tailwindcss-in-5-minutes-dc>

Configuration in Tailwind.config

### TypedEctoSchema

<https://hexdocs.pm/typed_ecto_schema/TypedEctoSchema.html?ref=blixt-dev>

### Kaffy

To be checked: <https://github.com/aesmail/kaffy?ref=blixt-dev>
