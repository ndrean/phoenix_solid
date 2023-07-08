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
