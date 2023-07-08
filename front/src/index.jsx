/* @refresh reload */
import { render } from "solid-js/web";
import { Socket } from "phoenix";
import { lazy } from "solid-js";
import { Router, Route, Routes, A } from "@solidjs/router";
import BauSolidCss from "bau-solidcss";

import phoenix from "./assets/phoenix.svg";
import context from "./context";
import styles from "./App.module.css";
import "./index.css";

// --------- SOCKET _______
const socket = new Socket("/socket", {
  params: { token: window.userToken },
});
socket.connect();
export { socket };
// -->

const { css, styled } = BauSolidCss();

const active = css`
  color: midnightblue;
  font-weight: bold;
  padding: 0.3em;
  border-radius: 5px;
  border: 2px solid;
  background-color: bisque;
  margin-right: 10px;
  text-decoration: none;
`;

const inactive = css`
  color: dodgerblue;
  border-radius: 5px;
  border: 2px solid;
  margin-right: 10px;
  padding: 0.3em;
  text-decoration: none;
`;

const flexed = css`
  display: flex;
`;
const Nav = (props) => styled("nav", props)`
  background-color: #282c34;
  padding: 1em;
  display: flex;
`;

function app(ctx) {
  history.pushState("", "", "/");
  const Home = lazy(() => import("./Home"));
  const Comp1 = lazy(() => import("./Comp1"));
  const Comp2 = lazy(() => import("./Comp2"));

  return (props) => (
    <div>
      <Nav>
        <A activeClass={active} inactiveClass={inactive} end href="/">
          Home
        </A>
        <A activeClass={active} inactiveClass={inactive} end href="/c1">
          Comp1
        </A>
        <A activeClass={active} inactiveClass={inactive} end href="/c2">
          Comp2
        </A>
        <a href="http://localhost:4000/welcome" class={inactive + " " + flexed}>
          <img src={phoenix} class={styles.phoenix} alt="phoenix" />
          <span>Phoenix</span>
        </a>
      </Nav>
      <Routes>
        <Route path="/" component={Home} />
        <Route path="/c1" component={Comp1} />
        <Route path="/c2" component={Comp2} />
      </Routes>
    </div>
  );
}

const root = document.getElementById("root");

if (import.meta.env.DEV && !(root instanceof HTMLElement)) {
  throw new Error(
    "Root element not found. Did you forget to add it to your index.html? Or maybe the id attribute got misspelled?"
  );
}

const App = app(context);
render(() => <Router>{App()}</Router>, root);
