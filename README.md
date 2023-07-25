# PhxSolid

This project demonstrates a way to run clustered containers of a Phoenix web app with a SPA embedded, backed by a PostgreSQL database and connected to a Livebook node to monitor the web app nodes. It also describes how you can set up authenticated websockets to share information or state between the Phoenix backend and the SPA.

<img width="478" alt="Screenshot 2023-07-25 at 17 03 43" src="https://github.com/ndrean/phoenix_solid/assets/6793008/ad0998dd-b608-42ae-b228-ae37e508d6a4">

The project describes recipes of how to include a [SolidJS](https://www.solidjs.com/) app in a Phoenix app  in two ways:

- embedded with a "hook" in a Liveview,
- or rendered on a separate page.

Why would you do this? Many apps are developed as hybrid web apps: a SPA communicating with a backend.
Why `SolidJS`? It is used because it is lightweight, doesn't use a VDOM and is almost as fast as Vanilla Javascript when compared to say `React`.

If you don't have navigation within the SPA, it can be useful to embed the Javascript into a hook. If you have navigation within the SPA (this is the case here), then you lose your Liveview connection.

What are the differences between the two options?

- the full page is built with `Vite` (with Esbuild and Rollup). The compilation of the full-page code is a custom process, run via a `Task`. The embedded version is compiled with `Esbuild` via a modified `mix assets.deploy`: you set up a custom "build" version of Esbuild. Rollup is _more performant_ than Esbuild to minimize the size of the bundles.
- to use authenticated websockets with an authenticated user, we need to [adapt the documentation](https://hexdocs.pm/phoenix/channels.html#using-token-authentication).

From the app, you can navigate to the LiveDashboard.

<img width="898" alt="Screenshot 2023-07-25 at 17 07 49" src="https://github.com/ndrean/phoenix_solid/assets/6793008/6cd70751-6586-4475-9dc4-eb5c601a6182">

You can connect to a Livebook. You can connect to the database as the cluster shares the same Docker network. This enables you not to open the Postgres database.

<img width="626" alt="Screenshot 2023-07-25 at 17 02 24" src="https://github.com/ndrean/phoenix_solid/assets/6793008/1e3b896c-c85e-42cf-abff-c612616e78de">

To communicate with the Phoenix app, you need authenticated websocket. An authentication is proposed (Google One Tap, using a Magic link login <https://johnelmlabs.com/posts/magic-link-auth> or anonymous account).

<details><summary>Authenticate websockets</summary>
We first generate a `Phoenix.Token`. When we use the embedded SPA, we pass this "user token" into the `conn.assigns` from a Phoenix controller and it will be available in the HTML "root.html.heex" template. It is hard coded, attached to the `window` object so Javascript is able to read it. For the backend Liveview, we pass it into a session so available in the `Phoenix.LiveView.mount/3` callback. The embedded version will be declared via a dataset `phx-hook` and rendered in a dedicated component. For the fullpage version, a controller will `Plug.Conn.send_resp` the compiled "index.html" file of the SPA. In the controller, we hard code the token (available in the "conn.assigns") into this file. Then Javascript will be able to read it and use it.
</details>

## "hooked" SPA

### Esbuild

You set up a custom `Esbuild` configuration to use the [custom plugin `solidPlugin`](https://github.com/amoutonbrady/esbuild-plugin-solid). Since SolidJS uses JSX for templating, we have to be sure Esbuild compiles the JSX files for **SolidJS**.

The Phoenix documentation explains [how to add a plugin](https://hexdocs.pm/phoenix/asset_management.html#esbuild-plugins). Esbuild will build the assets when we run the following function:

<details><summary>build.js</summary>

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
  build(opts);
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
}
```

</details>

The "config.exs" file will only contain the required version:

```elixir
# config.exs
config :esbuild,
  version: "0.17.11"
```

The documentation explains to modify the alias `mix assets.deploy` defined in the Mix.Project: you run `node build.js --deploy` in the "/assets" folder.

```elixir
"assets.deploy": [
  "tailwind default --minify",
  "cmd --cd assets node build.js --deploy",
  "phx.digest"
]
```

> Check how to [configure Tailwind with Phoenix](https://tailwindcss.com/docs/guides/phoenix)

Since we use code splitting, you will also need to:

- add "type=module" in the "my_app_web/components/layouts/root.html.heex" file as code splitting works with ESM (using `import`).

```html
<script defer phx-track-static type="module" type="text/javascript" src={~p"/assets/app.js"}></script>
```

- and declare you are using `"type": "module"` in "/assets/package.json"

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

#### Mount a SPA as a hook to a LiveView

We will mount a LiveView and render the SPA inside a component. This component has a dataset `phx-hook="solidAppHook"`. This hook references the SPA Javascript code.

```elixir
use Phoenix.Component
def display(assigns) do
  ~H"""
  <div id="solid" phx-hook="SolidAppHook" phx-update="ignore"></div>
  """
end
```

We attach to the property "hooks" of the `LiveSocket` (the one authenticated with the `_csrf_token`) the function that renders the SPA.

```js
//app.js
import { Socket } from "phoenix";
import { SolidAppHook } from "./solidAppHook';

new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: { SolidAppHook }
}).connect();

```

The code of the hook looks like this:

```js
//SolidAppHook.js
const SolidAppHook = {
  mounted(){import(...). then((App)=> render(...)}
}
```

You set up a "user_socket" and authenticate it in the backend with the "user token". We will attach a `channel`to have two ways of communication between the front and the back.

## Navigation with Phoenix/Liveview

Once you are authenticated via the sign-in, you are redirected to a Liveview. We set up a tab-like navigation where you can choose to navigate to the SPA in a full page or display the embedded SPA. On this page, all the code for the embedded SPA is already loaded.

Note that the SPA has an internal navigation. When you use it in the embedded version, you disconnect from the LiveView. The full-page version is also disconnected from the Liveview.

> An `on mount` function is run on each mount of the LiveView as [recommended by the doc](https://hexdocs.pm/phoenix_live_view/security-model.html#mounting-considerations).

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

- installed dependencies: install [phoenix.js](https://www.npmjs.com/package/phoenix)

```js
// /front/package.json
// ...
"devDependencies": {
    "solid-devtools": "^0.27.3",
    "vite": "^4.3.9",
    "vite-plugin-solid": "^2.7.0"
  },
  "dependencies": {
    "@solidjs/router": "^0.8.2",
    "bau-solidcss": "^0.1.15",
    "phoenix": "^1.7.6",
    "solid-js": "^1.7.6"
  }
```

- `Phoenix`: in the module "app_web.ex", add the folder "spa" to "static_paths" so the "endpoint.ex" gets the correct config through `plug Plug.Static, only: PhxSolidWeb.static_paths()`

```elixir
  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt) ++ ["spa"]
```

### Build the rendered SPA

We will compile the "front" files and copy them into the folder "priv/static/spa". We set up a [mix task](https://hexdocs.pm/mix/Mix.html) for this. Run this before anything.

```bash
mix spa --path="./priv/static/spa"
```

### Render the "non-hook" SPA

The route "/spa" will call the controller "spa_controller". It reads the compiled "index.html" file from the "priv/static/spa" folder and adds the "user_token" inside a "script" tag. To put this into the "head" tag, we added `<title>Solid app</title>` in the "index.html" file of the SPA. When we read the file line by line and encounter this particular line, we add the "script" tag" with the "user_token" value from the session. We end the controller with a `Plug.Conn.send_resp`.

Note that the file path is defined by the function below. We need to add `Application.app_dir(:phx_solid)` for the `mix release` task to find this file.

```elixir
defp index_html do
  Application.app_dir(:phx_solid) <> "/" <>
  System.get_env(:phx_solid, :spa_dir)
  <>  "index.html"
end
```

### Return from SPA to Phoenix

The SPA offers a navigation, in particular a link to return to Phoenix. We need to pass this via env variables. This is done with `Vite` with `import.meta.env.VITE_XXX`. Vite already has `dotenv` installed as [explained by the doc](https://vitejs.dev/guide/env-and-mode.html#env-files). You can use just like this to reference the URL to which we want to navigate back.

```js
<a href={import.meta.env.VITE_RETURN_URL}>...</a>
```

```bash
# .env
VITE_RETURN_URL=http://localhost:4000/welcome
```

> this has to be tested when deployed for real !!!

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

It is an object that holds the WS. We will set up the socket SPA side and server side. We generate the 2 files - server & client - needed to handle bith sides of the socket. As previously stated, make sure the npm package `Phoenix.js` is installed in the SPA.

```bash
mix phx.gen.socket User
cd front && pnpm i phoenix
```

#### Client-side

In the SPA's "index.jsx" file (where we `render`), we instantiate the socket connection with the `Socket` object and pass along the `user_token` read from the DOM. It will be available in the query string of the "ws", hence params, and is received server-side to authenticate and thus permit the connection.

```js
// userSocket.js
import { Socket } from "phoenix";

const socket = new Socket("/socket", {
  params: { token: window.userToken },
});

if (window.userToken) socket.connect();

export default socket;
```

We also built a helper `useChannel`. It attaches a channel to the socket with a topic and returns the channel, ready to be used (`.on`, `.push`). Use it every time you need to create a channel and communicate with the backend. It has a cleaning stage in its life cycle. For example, the SPA has navigation; when we use a page, it opens a channel for the data on this page, and when we leave this page, this channel is closed.

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

### Channels

A channel is an Elixir process derived from a Genserver: it is therefore capable of emitting and receiving messages. It is uniquely identified by a string and attached to the `socket` which accepts a list of channels. This is done in the _UserSocket_ module.

Whenever we `push` data through a channel client-side, its alter ego server-side will receive it in a callback `handle_in`.
We can push data from the server to the client through the socket with a `broadcast!(topic, event, message)` or `push` related to a topic. The client will receive it with the listener `channel_topic.on(event, (resp)=>{...})`.

To set up a channel, use the generator:

```bash
mix phx.gen.channel Counter
```

We create channels per piece of UI state we want to save. For example, we count the number of times the SPA landing page is reached. We save this counter as a **singleton table** (one row). Th

## Docker

### Dockerfile

It is a 3 stages process with Debian 11 based images:

- a builder stage for the full page SPA based on a NodeJS 18 Debian 11 based image. In dev non-docker mode, you can build "by hand" `mix spa --path="./priv/static/spa"`. This stage is used to differenciate the rebuild from the hooked version.
- a builder stage for the Phoenix app and its JS assets, based on Elixir with NodeJS injected, and produce a release and compiled JS assets. We inject the full page SPA here.
- the final "runner" stage to deliver a minimal Debian-based image.

> We need to install `nodejs` and `npm`, then `pnpm` as (curiously???) NPM didn't accept "link:../deps/phoenix..".

### Docker-Compose and Postgres init

We run 4 services: 2 instances of the web app, the Postgres database and a Livebook.

To start a Postgres container, it is enough to pass the env variables `POSTGRES_PASSWORD`, `POSTGRES_USER` and `POSTGRES_DB`. This will create a database.

The web app uses a `DATABASE_URL` env variable in the form below. Note that the "hostname" is the **service name\*** (and not "localhost" as in dev non-docker mode)

```elixir
ecto://<user>:<pass>@<service>/<POSTGRES_DB_{MIX_ENV}>
```

To run the migrations, we will use the Docker entrypoint "docker-entrypoint-initdb.d" and bind the `init.sql` file from the host into this directory of the Postgres container.

To generate this file, we use the [code generated by the migration in DEV mode](https://hexdocs.pm/ecto_sql/Mix.Tasks.Ecto.Migrate.html#module-command-line-options):

```elixir
mix ecto.migrate --log-migrations-sql > ./init.sql
```

It will remain to clean this file to play it.

<details>
<summary>--- The docker-compose file ---</summary>

```bash
version: "3.9"

volumes:
  pg-data:

networks:
  mynet:

x-web-app: &commun-web-app
  image: phx_solid
  depends_on:
    - db
  environment:
    RELEASE_DISTRIBUTION: sname
  env_file:
    - .env-docker
  networks:
    - mynet

services:
  db:
    image: postgres:15.3-bullseye
    env_file:
      - .env-docker
    restart: always
    networks:
      - mynet
    volumes:
      - pg-data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    ports:
      - "5432"

  livebook:
    image: ghcr.io/livebook-dev/livebook
    networks:
      - mynet
    depends_on:
      - db
    environment:
      - MIX_ENV=prod
      - LIVEBOOK_DISTRIBUTION=sname
      - LIVEBOOK_COOKIE=supersecret
      - LIVEBOOK_PASSWORD=securesecret
      - SECRET_KEY_BASE=HRPM+KVxrXtYiIni27wn1pXrNc/cl7wjHl/u5TWQxqZkuvJ6Q4NBF+WMUVUpQVIY
    hostname: livebook
    volumes:
      - ./data:/data/
    ports:
      - "8080:8080"
      - "8081:8081"

  app0:
    <<: *commun-web-app
    hostname: app0
    ports: - "4000:4000"

  app1:
    <<: *commun-web-app
    hostname: app1
    ports: - "4001:4000"
```

</details>

To build this, run:

```bash
docker build -t phx_solid .
docker-compose up
```

In the Livebook container, we will bind a local folder to the "/data" folder to save the ".livemd" file that contains the markdown we want to run in the Livebook.

You may use `Base.url_encode64(:crypto.strong_rand_bytes(40))` to generate the env variable `RELEASE_COOKIE`.

### Livebook node discovery

To enable node discovery, add the `libcluster` dependency and the same code as in the web app:

```elixir
topologies = [gossip: [strategy: Cluster.Strategy.Gossip]]

children = [
  {Cluster.Supervisor, [topologies, [name: Lv.ClusterSupervisor]]}
]

opts = [strategy: :one_for_one, name: PhxSolid.Supervisor]
Supervisor.start_link(children, opts)
```

Since the Livebook node is hidden, you need to set up the node monitoring as below if you want to capture a `:nodeup` (or down) event:

```elixir
:net_kernel.monitor_nodes(true, %{node_type: :all})
```

You can check:

```elixir
Node.list(:connected)
```

```elixir
:rpc.call(:"phx_solid@app0", PhxSolid.Repo, :get_by, [PhxSolid.SocialUser, %{id: 1}])
```

## State persistence

With "standard" SSR, the backend manages the state, and the UI is a simple rendering machine
The SPA itself can use state management. Since it is lost each time you disconnect, it may need to be persisted. We used a "context" pattern in the SPA.
We could set up a Redis session or use the database. If the app is distributed, most probably Redis or the database should be used.

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

### Content Security Policy

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

Litestream: <https://litestream.io/>. Stream the db.

[Migration in a release without Mix installed](https://hexdocs.pm/phoenix/releases.html#ecto-migrations-and-custom-commands): "release.ex"

In "application.ex", do:

```elixir
 PhxSolid.Release.migrate()
```

[Upserts with SQLite3](https://www.sqlite.org/lang_UPSERT.html) works when the target field has a unique constraint (`create unique_index` in the migration):

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

[Sqlite3 CLI](https://www.sqlite.org/cli.html) (dot notation):

```bash
~/phx_solid/db> .open phx_solid.db
sqlite> .mode tabs
sqlite> select * from social_users;
sqlite .quit
```

### CSS Typewriter

Typewriter effect: <https://dev.to/lazysock/make-a-typewriter-effect-with-tailwindcss-in-5-minutes-dc>

Configuration in Tailwind.config

### TypedEctoSchema

<https://hexdocs.pm/typed_ecto_schema/TypedEctoSchema.html?ref=blixt-dev>

### Kaffy

To be checked: <https://github.com/aesmail/kaffy?ref=blixt-dev>

### Caddy

Use `Caddy server` to reverse-proxy Cowboy. The Facebook login will work. Just do:

```bash
caddy reverse-proxy --from :80 --to: 4000
# or if you use a config file:
caddy run Caddyfile
```

Alternatively, you can use:

```bash
mix phx.gen.cert
```

and modify your "config.exs":

```elixir
config :phx_solid, PhxSolidWeb.Endpoint,
  https: [
  port: 4001,
  cipher_suite: :strong,
  certfile: "priv/cert/selfsigned.pem",
  keyfile: "priv/cert/selfsigned_key.pem"
]
```

With Chrome, set up "enable" on `chrome://flags/#allow-insecure-localhost`
