import { Socket } from "phoenix";

let socket = new Socket("/socket", {
  params: { token: window.userToken },
});
if (window.userToken) socket.connect();

export default socket;
