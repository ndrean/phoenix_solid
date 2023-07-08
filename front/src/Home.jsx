import { createSignal } from "solid-js";

import logo from "./assets/logo.svg";
// import phoenix from "./assets/phoenix.svg";
import styles from "./App.module.css";
import useChannel from "./useChannel";
import { socket } from "./index.jsx";

export default function Home() {
  const [info, setInfo] = createSignal("");
  useChannel(socket, "info").on("get_info", (resp) => setInfo(resp));

  return (
    <div class={styles.App}>
      <header class={styles.header}>
        <h1>Phoenix renders SolidJS</h1>
        <a href="https://github.com/solidjs/solid" target="_blank">
          <img src={logo} class={styles.solid} alt="solid" />
        </a>
        <rb />
        <p>Memory usage: {info().memory} Mo</p>
        <p>Current node: {info().curr_node}</p>
        <p>Connected nodes: {info().connected_nodes}</p>
      </header>
    </div>
  );
}
