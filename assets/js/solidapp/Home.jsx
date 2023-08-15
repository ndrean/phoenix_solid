import { createEffect, createSignal, For } from "solid-js";
import ChartCoin from "./ChartCoin";
import Chart from "./Chart";
import ImgSVG from "./imgSVG.jsx";
import BauSolidCss from "bau-solidcss";
import { headerCl, solidCl, appCl } from "./app_css.js";
// import styles from "./App.module.css";
// class={styles.header}

import useChannel from "../useChannel.js";
import socket from "../userSocket.js";

const { css } = BauSolidCss();
const chartCss = css`
  display: flex;
  justify-content: center;
`;

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
    if (Object.keys(resp).includes("up")) {
      setNodeEvt(`⬆️ ${resp.up}`);
      console.log(resp.list);
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

  const bitcoinCh = useChannel(socket, "bitcoin");
  const [stock, setStock] = createSignal(
    { labels: [], datasets: [{ label: "bitcoin", fill: false, data: [] }] },
    { equals: false }
  );
  bitcoinCh.on("new_btc_price", ({ time, bitcoin }) => {
    console.log("entry", new Date(time), { bitcoin });
    const evtTime = new Date(time).toLocaleTimeString();
    setStock((curr) => {
      if (curr.labels.length > 120) {
        curr.labels.shift();
        curr.labels.push(evtTime);
        curr.datasets[0].data.shift();
        curr.datasets[0].data.push(parseFloat(bitcoin).toFixed(2));
      } else {
        curr.labels.push(evtTime);
        curr.datasets[0].data.push(parseFloat(bitcoin).toFixed(2));
      }
      return curr;
    });
  });

  createEffect(() => {
    console.log("stock", stock());
  });

  return (
    <div class={appCl}>
      <header class={headerCl}>
        <h1>Welcome {info().user}</h1>
        <br />
        <p class={solidCl}>
          <ImgSVG
            class={solidCl}
            alt="solid"
            src="/images/solid.svg"
            size="80px"
          />
        </p>
        <br />
        <div class={chartCss}>
          <ChartCoin data={stock()} />
        </div>

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
