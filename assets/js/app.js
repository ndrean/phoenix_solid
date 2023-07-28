// If you want to use Phoenix channels, run `mix help phx.gen.channel`
import "./userSocket.js";
import onlineStatus from "./onlineStatus.js";
import { Facebook } from "./facebook";
import { SolidAppHook } from "./solidAppHook.js";
// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "topbar";

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: { SolidAppHook },
});
liveSocket.connect();

// connect if there are any LiveViews on the page
// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
// window.liveSocket = liveSocket;

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// GOOGLE-ONE-TAP
// const oneTap = document.querySelector("#g_id_onload");
// if (oneTap)
//   oneTap.dataset.login_uri = window.location.origin + "/auth/one_tap/";

//  FB-SDK
const fbutton = document.querySelector("#fb-btn");
if (fbutton) Facebook(fbutton);

const online = document.getElementById("online");
if (online) onlineStatus(online);

// const btn = document.getElementById("btnDiv");
// if (btn) {
//   console.log(btn);
//   const div = document.createElement("div");
//   div.classList.add("g-signin2");
//   div.dataset.onsuccess = "onSignIn";
// }
