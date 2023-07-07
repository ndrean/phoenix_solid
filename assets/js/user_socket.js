// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

import { Socket, Presence } from "phoenix";

// And connect to the path in "lib/live_map_web/endpoint.ex". We pass the token for authentication. Read below how it should be used.
let socket = new Socket("/socket", {
  params: { token: window.userToken },
});

socket.connect();

window.addEventListener("phx:new_channel", ({ detail: { from, to } }) => {
  const channel = setChannel(from, to);
  channel
    .join()
    .receive("ok", (resp) => {
      console.log("Joined channel: ", from, to);
    })
    .receive("error", (resp) => {
      console.log("Unable to join", resp);
    });
  channel.on("shout", (p) => console.log("shouted", p));
});

function setChannel(x, y) {
  const ch = [x, y].sort().join("-");
  // const ch = x < y ? `chat:${x}-${y}` : `chat:${y}-${x}`;
  return socket.channel(ch, { to: x, from: y });
}

// const ch = setChannel(1, 3, "1-3");
// ch.join()
//   .receive("ok", (res) => console.log("Private room 1-3", res))
//   .receive("error", ({ reason }) => console.log("failed join", reason));

// const presenceChannel = socket.channel("presence");

// const presence = new Presence(presenceChannel);
// presence.onSync(() => {
//   console.log(presence.list(), "onSync");
// });

export { socket };

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/live_map_web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/live_map_web/templates/layout/app.html.heex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/live_map_web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
