/* @refresh reload */
import { render } from "solid-js/web";
import { Socket } from "phoenix";
import { lazy } from "solid-js";
import { Router, Route, Routes, A } from "@solidjs/router";
import BauSolidCss from "bau-solidcss";

import { active, inactive, flexed, mainNav, img, Nav } from "./indexCss";
import { phoenixCl } from "./appCss";
import phoenix from "./assets/phoenix.svg";
import context from "./context";
import { onlineListener } from "./onlineListener";

// --------- SOCKET _______
const socket = new Socket("/socket", {
  params: { token: window.userPhxToken },
});
socket.connect();
console.log("userphxtoken", window.userPhxToken);
console.log({ socket });
export { socket };
// -->

const { createGlobalStyles } = BauSolidCss();

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

/*
const mainNav = css`
  display: flex;
  justify-content: space-between;
  align-content: center;
  align-items: stretch;
  background-color: #282c34;
`;

const img = css`
  display: flex;
  align-items: center;
`;

const Nav = (props) => styled("nav", props)`
  padding: 1em;
  display: flex;
`;

*/
function app(ctx) {
  history.pushState("/", "", "/");
  const Home = lazy(() => import("./Home"));
  const Comp1 = lazy(() => import("./Comp1"));
  const Comp2 = lazy(() => import("./Comp2"));

  console.log("return", import.meta.env.VITE_RETURN_URL);

  return (props) => (
    <div>
      <div class={mainNav}>
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
            // href={import.meta.env.VITE_RETURN_URL}
            href={window.location.origin + "/welcome"}
            class={inactive + " " + flexed}
          >
            <img src={phoenix} class={phoenixCl} alt="phoenix" />
            <span>Phoenix</span>
          </a>
        </Nav>

        <div class={img}>
          {/* https://www.solidjs.com/docs/latest#ref */}
          <img ref={(el) => onlineListener(el)} alt="online-status" />
        </div>
      </div>
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
