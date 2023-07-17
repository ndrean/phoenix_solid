import { createEffect, createSignal } from "solid-js";

import ImgSVG from "./imgSVG.jsx";
import { headerCl, solidCl, appCl } from "./app_css.js";
// import styles from "./App.module.css";
// class={styles.header}

import useChannel from "../useChannel.js";
import { socket } from "../user_socket.js";

export default function Home() {
  const [info, setInfo] = createSignal("");
  const [visits, setVisits] = createSignal(0);

  const infoCh = useChannel(socket, "info");
  infoCh.on("get_info", (resp) =>
    resp.status === "unauthorized" ? channel.leave() : setInfo(resp)
  );

  const visitCh = useChannel(socket, "counter");
  visitCh.on("init_count", (resp) => setVisits(resp.count));

  return (
    <div class={appCl}>
      <header class={headerCl}>
        <h1>Phoenix renders SolidJS</h1>
        <br />
        <p class={solidCl}>
          <ImgSVG
            class={solidCl}
            alt="solid"
            src="/images/solid.svg"
            size="160px"
          />
        </p>
        <br />

        <h2>Welcome {info().user}</h2>
        <p>This page has been visited {visits()} time(s)</p>
        <p>Memory usage: {info().memory} Mo</p>
        <p>Current node: {info().curr_node}</p>
        <p>Connected nodes: {info().connected_nodes}</p>
      </header>
    </div>
  );
}
