import { createSignal } from "solid-js";

import logo from "./assets/logo.svg";

// import styles from "./App.module.css";
// class={styles.app}

import { headerCl, appCl, solidCl } from "./appCss";
import useChannel from "./useChannel";
import { socket } from "./index.jsx";

export default function Home() {
  const [info, setInfo] = createSignal("");
  const channel = useChannel(socket, "info");
  channel.on("get_info", (resp) =>
    resp.status === "unauthorized" ? channel.leave() : setInfo(resp)
  );

  return (
    <div class={appCl}>
      <header class={headerCl}>
        <h1>Phoenix renders SolidJS</h1>
        <br />
        <img src={logo} class={solidCl} alt="solid" />
        <br />
        <h2>Welcome {info().user}</h2>
        <p>Memory usage: {info().memory} Mo</p>
        <p>Current node: {info().curr_node}</p>
        <p>Connected nodes: {info().connected_nodes}</p>
      </header>
    </div>
  );
}
