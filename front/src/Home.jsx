import { createEffect, createSignal, For } from "solid-js";

import logo from "./assets/logo.svg";

// import styles from "./App.module.css";
// class={styles.app}

import { headerCl, appCl, solidCl } from "./appCss";
import useChannel from "./useChannel";
import { socket } from "./index.jsx";

export default function Home() {
  const [info, setInfo] = createSignal(
    { memory: 0, connected_nodes: [], curr_node: "", user: "" },
    { equals: false }
  );
  const [visits, setVisits] = createSignal(0);
  const [nodeEvt, setNodeEvt] = createSignal("");

  const infoCh = useChannel(socket, "info");
  infoCh.on("get_info", (resp) =>
    resp.status === "unauthorized" ? channel.leave() : setInfo(resp)
  );
  infoCh.on("nodes_event", (resp) => {
    // setInfo((current) => (current.connected_nodes = resp.list));
    if (Object.keys(resp).includes("up")) {
      setNodeEvt(`⬆️  ${resp.up}`);
      setInfo((current) => {
        current.connected_nodes = resp.list;
        return current;
      });
    }
    if (Object.keys(resp).includes("down")) {
      setNodeEvt(`⬇️ ${resp.down}`);
      setInfo((current) => {
        current.connected_nodes = resp.list;
        return current;
      });
    }
  });

  const visitCh = useChannel(socket, "counter:visits");
  visitCh.on("init_count", (resp) => setVisits(resp.count));

  return (
    <div class={appCl}>
      <header class={headerCl}>
        <h1>Phoenix renders SolidJS</h1>
        <br />
        <img src={logo} class={solidCl} alt="solid" />
        <br />
        <h2>Welcome {info().user}</h2>
        <p>This page has been visited {visits()} time(s)</p>
        <p>Memory usage: {info().memory} Mo</p>
        <br />
        <p>Current node: {info().curr_node}</p>
        <p>Node event: {nodeEvt()}</p>
        <p>Connected nodes:</p>
        <ul>
          <For each={info().connected_nodes}>{(node) => <li>{node}</li>}</For>
        </ul>
      </header>
    </div>
  );
}
