/* @refresh reload */
import { render } from "solid-js/web";
import { Socket } from "phoenix";
import { lazy } from "solid-js";
import { Router, Route, Routes, A } from "@solidjs/router";
import BauSolidCss from "bau-solidcss";

import { active, inactive, flexed } from "./indexCss";
import { phoenixCl } from "./appCss";
import phoenix from "./assets/phoenix.svg";
import context from "./context";
// import styles from "./App.module.css";

// --------- SOCKET _______
const socket = new Socket("/socket", {
  params: { token: window.userToken },
});
socket.connect();
export { socket };
// -->

const { css, styled, createGlobalStyles } = BauSolidCss();

createGlobalStyles`
  body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}
`;

const Nav = (props) => styled("nav", props)`
  background-color: #282c34;
  padding: 1em;
  display: flex;
`;

function app(ctx) {
  history.pushState("/", "", "/");
  const Home = lazy(() => import("./Home"));
  const Comp1 = lazy(() => import("./Comp1"));
  const Comp2 = lazy(() => import("./Comp2"));

  console.log("return", import.meta.env.VITE_RETURN_URL);
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
        <a
          href={import.meta.env.VITE_RETURN_URL}
          class={inactive + " " + flexed}
        >
          <img src={phoenix} class={phoenixCl} alt="phoenix" />
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

const spa = document.getElementById("spa");
const App = app(context);
render(() => <Router>{App()}</Router>, spa);
