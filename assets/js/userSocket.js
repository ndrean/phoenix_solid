import { Socket } from "phoenix";

const socket = new Socket("/socket", {
  params: { token: window.userPhxToken },
});
if (window.userPhxToken) socket.connect();

export default socket;
