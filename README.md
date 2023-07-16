# PhxSolid

We present a Phoenix app that starts as a normal Phoenix SSR app. It will render two versions of an JS SPA: one an embeddedwithin a hook, and the other rendered in a separate page.

The SPA will commmunicate with the Phoenix node through an authenticated websocket. Channels will be set up to maintain the state of the SPA as well as push information from the backend to the SPA.

The SPA uses [SolidJS](https://www.solidjs.com/).

What is the difference between the two options? The built version of the SPA has code splitting with 9 files produced, the main chunk is 50k, and a total of 55kb unzipped (compiled with `vite build` using `Rollup`)). The embedded version ships "app.js" and the "spa.js" with respective size of 130kb and 55kb (compiled with Esbuild via `node build.js --deploy`)

## Boilerplates

### Phoenix

```bash
mix phx.new phx_solid
```

### SolidJS: **"hooked"**

#### Esbuild

In this case, you need to modify the `Esbuild` configuration given in Phoenix. Since SolidJS uses JSX for templating, we have to be sure Esbuild compiles for **SolidJS** files and not for _React_. It is explained in the Phoenix doc how to add a plugin.

<https://hexdocs.pm/phoenix/asset_management.html#esbuild-plugins>

We followed the doc, build the file `/assets/build.js`, run it (`node build.js`) and modified the "dev.config".

The "config.exs" file will only contain the version:

```elixir
# config.exs
config :esbuild,
  version: "0.17.11"
```

Instead of doing `mix assets.deploy`, you do (in the "assets" folder) `node build.js --deploy`.

#### Mount an SPA as a hook to a Liveview

We will mount a LiveView and render a component. This component has a "hook" attached, declared via a dataset `phx-hook=solidAppHook` in the HTML. This hook references the SPA JS code.

```elixir
use Phoenix.Component
def display(assigns) do
  ~H"""
  <div id="solid" phx-hook="SolidAppHook" phx-update="ignore"></div>
  """
end
```

Firstly navigate to the "assets" folder and install the dependencies:

```json
"dependencies": {
   "@solidjs/router": "^0.8.2",
   "bau-solidcss": "^0.1.14",
   "phoenix": "file:../deps/phoenix",
   "phoenix_html": "file:../deps/phoenix_html",
   "phoenix_live_view": "file:../deps/phoenix_live_view",
   "solid-js": "^1.7.7"
 },
 "devDependencies": {
   "esbuild": "^0.18.11",
   "esbuild-plugin-solid": "^0.5.0"
 }
```

```bash
cd assets
pnpm init
pnpm install
```

We will attach an object "hook" to the `LiveSocket` (the one authneticated with the `_csrf_token`). This "hook" will contain the code of the SPA.

```js
//app.js
import { Socket } from "phoenix";

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: { SolidAppHook },
});
```

The code of the hook will run the main function of the SPA.

```js
//SolidAppHook.js
const SolidAppHook = {
  mounted(){import(...). then((App)=> render(...)}
}
```

The component will be stateless, but it can be statefull as well. The communication between the Javascript and Elixir will happen through the websocket. To this websocket, we will attach a `channel`, a Genserver with a pubsub. With this in place, we will be able to have two ways communication. The state will be maintained in the Liveview.

> The SPA offers a navigation, in particular a link to return to Phoenix. We need to pass this via env variables. This is done with `Vite` with `import.meta.env.VITE_XXX`. Vite already has `dotenv` installed. All this is [explained by the doc](https://vitejs.dev/guide/env-and-mode.html#env-files). You can use just like this to reference the URL to which we want to navigate back.

```js
<a href={import.meta.env.VITE_RETURN_URL}>...</a>
```

```bash
# .env
VITE_RETURN_URL=http://localhost:4000/welcome
```

#### Mix assets.deploy

Since we run the function "build.js", we need to modify the command in the "aliases" function as:

```elixir
defp aliaises do
[
  "assets.deploy": [
    "tailwind default --minify",
    "cmd --cd assets node build.js --deploy",
    "phx.digest"
  ]
]
```

Remember, `mix phx.digset.clean --all`

## Navigation with Phoenix/Liveview

Once you are authenticated via the sign-in, you are redirected to a Liveview. We set up a [tab like navigation](https://dev.to/ndrean/breadcumbs-with-phoenix-liveview-2d40) where you can choose to render the SPA in a full page or run the embedded SPA.

The full page SPA will be the "built" version and be rendered by `Plug.Conn.send_resp`.

An `on mount` function is run on each mount of the liveview as [recommended by the doc](https://hexdocs.pm/phoenix_live_view/security-model.html#mounting-considerations).

### SolidJS: **non hook**

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

- `Phoenix`: in the module "app_web.ex", add the folder "spa" to "static_paths"

```elixir
  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt) ++ ["spa"]
```

so the "endpoint.ex" gets the correct config:

```elixir
#endpoint.ex
plug Plug.Static,
  at: "/",
  from: :phx_solid,
  gzip: false,
  cache_control_for_etags: "public, max-age = 31_536_00",
  only: PhxSolidWeb.static_paths()
```

### Build the rendered SPA

We will compile the JS/CSS and copy the files into the folder "priv/static/spa":

```elixir
# config.exs
Application.compile_env!(:phx_solid, :spa_dir)
# .env
 = System.fetch_env!("SPA_DIR")
 = "./priv/static/spa`
```

We set up a [mix task](https://hexdocs.pm/mix/Mix.html) to compile and copy. It uses the behaviour "Mix.Task" and provides a `call/1` function to run these tasks.

```bash
mix spa
```

### SPA rendering

The compiled files are located in the "priv/state/spa" (declared in our "config.exs").

We set up an endpoint "/spa" to render the SPA. The corresponding controller will read the compiled "index.html" + associated JS + CSS files. It will also inject into the file a `user_token` from the session, and attached it to the `window` object via a script: the browser will read it. We render these files with `Phoenix.Controller.html(conn, file)`.

Each time we will navigate to the build version, Phoenix will inject the current `user_token`. This will garantee the validity of the websocket connection since we will check the token with the alter eog function `Phoenix.Token.verify`

## Generate a token per user

We generate a token per user's email (or id) after the sign-in.

```elixir
Phoenix.Token.sign(PhxSolidWeb.Endpoint,"user_token", email )
```

## Passing data between Plug (HTTP) and Liveview

We insert this token (or user.id) into the `session` with `Plug.Conn.put_session(conn, key, value)`. Any plug has access to the session, as well as Liveview in the `mount/3`.

## Passing data from Phoenix to the SPA

We also inject

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

## Misc

### Add Google One Tap

To enable **Google One tap**, there is a module `:google_certs`. It needs the dependencies

```elixir
{:jason, "~> 1.4"},{:joken, "~> 2.5"}
```

`Joken` will bring in `JOSE` which I used to decrrypt the PEM version.

#### Google credentials

You will need credentials from Google.

- create a project in the <https://console.cloud.google.com>
- then create credentials as a **web application**
- ⚠️ the "Authorized Javascript origins" should contain **2** fields, with AND without the port.

You set up a "one_tap_controller". It is a POST endpoint and will receive a response from Google. It will set a `user_token` and the users' `profile` in the session, and redirect to a "welcome" page.

<img width="502" alt="Screenshot 2023-07-07 at 16 51 37" src="https://github.com/ndrean/phoenix_solid/assets/6793008/b07428c8-1722-49f9-9003-6f9b513eb1e4">

#### Source .env

Don't forget to add the crendetials in ".env".

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

We could further reduce the load on the Phoenix backend by using a reverse proxy (Nginx > Caddy) with cache control. It would serve the static files and pass the WS connections and HTTP connections to the backend. Target is "localhost:80" ot point to the Cowboy web-server at "localhost:4000".

#### Nginx

Relative paths in Nginx are resolved based on the Nginx installation directory, not the current working directory or the location of the configuration file.

Run an Nginx image in detached mode (background mode). Name the container "web". We run the command "nginx":

```bash
docker run -it --rm -d -p 8080:80 --name web  nginx
# stop it
docker stop web

```

Enter in it and check:

```bash
docker run -it --rm -d -p 8080:80 --name web  nginx
ls /usr/share/nginx/
```

Create a folder "rp" and insert an "index.html" file. Then bind it into the container:

```bash
docker run -it --rm -d -p 8080:80 --name web -v ./rp:/usr/share/nginx/html nginx
```

It should work. Automate this with a Dockerfile (located in the folder /docker/nginx). The image will use the underlying `entrypoint` and `cmd` provided by the NGINX image.

```bash
docker build -t webserver -f ./docker/nginx/Dockerfile .
# check
docker images
# run a container from the image
docker run -it --rm -p 80:80 --name web -v $(pwd)/solid.conf:/etc/nginx/conf.d/default.conf webserver
# check
docker ps

```

Check `nginx` local config:

```bash
nginx -c $(pwd)/config.conf -t
#check listening port
lsof -i :80

```

```bash

```

and recompile the SPA so that

### SQLITE

- migration in a release without Mix installed: "release.ex"

- check after migration

```bash
mix ecto.create
mix ecto.gen.migration create_users_table
mix ecto.migrate
sqlite3 phx_solid_dev .schema
```

```elixir
PhxSolid.Repo.get_by!(PhxSolid.User, %{id: 1})
```

Upserts with SQLite3 works when the target field has a unique constrainte (`create unique_index` in te migration): <https://www.sqlite.org/lang_UPSERT.html>

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
